
##
## This module implements a stream http multipart parser
## depends on chronos StreamTransport
##
## Copyright (c) 2020 Bung

import streams, os, oids, strformat
import chronos
import parseutils, strutils # parseBoundary
import constant

type 
  MultipartState* = enum
    boundaryBegin, boundaryEnd, contentEnd, disposition, contentBegin
  MultipartParser* = ref object
    boundaryBegin, boundaryEnd: string
    boundaryBeginLen, boundaryEndLen: int
    state*: MultipartState
    dispositionIndex:int
    contentLength:int
    transp:StreamTransport
    tmpRead:int
    aSlice:Slice[int] # store name,value pair indexes
    bSlice:Slice[int]
    read:int
    buf: ptr char
    src: ptr array[HttpRequestBufferSize,char]
    dispositions*: seq[ContentDisposition]
  ContentDispositionKind* = enum
    data, file
  ContentDisposition* = ref object
    name*:string
    case kind*:ContentDispositionKind
      of data:
        value*:string
      of file:
        filename*,contentType*,contentDescription*,contentLength*,transferEncoding*:string
        filepath*:string
        file:FileStream

proc `$`*(x:ContentDisposition):string =
  if x.kind == data:
    result = fmt"""{{"name":"{x.name}", "value": "{x.value}"}}"""
  elif x.kind == file:
    result = fmt"""{{"name":"{x.name}", "filename":"{x.filename}", "contentType": "{x.contentType}", "transferEncoding": "{x.transferEncoding}", "filepath": {x.filepath} }}"""

template `+`[T](p: ptr T, off: int): ptr T =
    cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

template `+=`[T](p: ptr T, off: int) =
  p = p + off

proc parseBoundary*(line: string): tuple[i:int,boundary:string] = 
  # retrieve boundary from Content-Type
  const Flag = "multipart/form-data;"
  # const FlagLen = Flag.len
  const BoundaryFlag = "boundary="
  result.i = line.find(Flag)
  if result.i > -1:
    if line.find('"',result.i ) == -1:
      let j = line.find(BoundaryFlag,result.i )
      if j != -1:
        result.boundary = line[j + BoundaryFlag.len  ..< line.len]
    else:
      let j = line.find(BoundaryFlag,result.i )
      if j != -1:
        result.boundary = captureBetween(line,'"','"',j + BoundaryFlag.len)

proc newMultipartParser*(boundary:string, transp:StreamTransport, src:ptr array[HttpRequestBufferSize,char], contentLength: int): MultipartParser =
  new result
  result.state = boundaryBegin
  result.boundaryBegin = "--" & boundary
  result.boundaryEnd = "--" & boundary & "--"
  result.boundaryBeginLen = result.boundaryBegin.len
  result.boundaryEndLen = result.boundaryEnd.len
  result.transp = transp
  result.src = src
  result.buf = src[0].addr
  result.contentLength = contentLength

proc remainLen(parser:MultipartParser):int =
  parser.contentLength - parser.read

proc needReadLen(parser: MultipartParser): int =
  min(parser.remainLen, HttpRequestBufferSize)

proc currentDisposition(parser:MultipartParser):ContentDisposition{.inline.} =
  parser.dispositions[parser.dispositionIndex]

proc skipWhiteSpace(parser:MultipartParser) =
  # skip possible whitespace between value's fields
  if parser.buf[] == ' ':
    parser.buf += 1

proc isBoundaryBegin(parser:MultipartParser):bool{.inline.} =
  result = true
  for i in 0 ..< parser.boundaryBeginLen:
    if (parser.buf + i)[] != parser.boundaryBegin[i]:
      return false

proc isBoundaryEnd(parser:MultipartParser):bool {.inline.}=
  result = true
  for i in 0 ..< parser.boundaryEndLen:
    if (parser.buf + i)[] != parser.boundaryEnd[i]:
      return false

proc skipContentDispositionFlag(parser:MultipartParser) =
  # Content-Disposition (case senstitive)
  const ContentDispoitionFlagLen = "Content-Disposition:".len
  parser.buf += ContentDispoitionFlagLen

proc skipFormDataFlag(parser:MultipartParser) =
  const FormDataFlagLen = "form-data;".len
  parser.buf += FormDataFlagLen

proc getName(parser:MultipartParser):string =
  # skip name="
  parser.buf += 6
  while parser.buf[] != '"':
    result.add parser.buf[]
    parser.buf += 1
  parser.buf += 1

proc hasMoreField(parser:MultipartParser):bool = 
  result = parser.buf[] == ';'
  if result:
    parser.buf += 1

proc getFileName(parser:MultipartParser):string =
  # skip filename="
  parser.buf += 10
  while parser.buf[] != '"':
    result.add parser.buf[]
    parser.buf += 1
  parser.buf += 1

proc skipLineEnd(parser:MultipartParser) =
  if parser.buf[] == '\c' and (parser.buf + 1)[] == '\l':
    parser.buf += 2

proc skipBeginTok(parser:MultipartParser) =
  parser.buf += parser.boundaryBeginLen

proc validateBoundary(parser:MultipartParser, line: string):bool =
  line == parser.boundaryBegin

proc skipEndTok(parser:MultipartParser) =
  parser.buf += parser.boundaryEndLen

proc aStr(parser:MultipartParser):string {.inline.}=
  parser.aSlice.b -= 1
  cast[string](parser.src[parser.aSlice])

proc bStr(parser:MultipartParser):string {.inline.}=
  parser.bSlice.b -= 1
  cast[string](parser.src[parser.bSlice])

proc takeASlice(parser:MultipartParser) {.inline.} =
  parser.bSlice.a = parser.aSlice.b 
  parser.bSlice.b = parser.aSlice.b 

proc incBSlice(parser:MultipartParser) {.inline.} =
  inc parser.bSlice.a
  inc parser.bSlice.b

proc resetSlices(parser:MultipartParser) {.inline.} =
  parser.aSlice = default(Slice[int])
  parser.bSlice = default(Slice[int])

proc skipWhiteSpaceAndIncBSlice(parser:MultipartParser) =
  # skip possible whitespace between value's fields
  if parser.buf[] == ' ':
    parser.buf += 1
    parser.incBSlice

proc parseParam(parser:MultipartParser){.inline.} =
  # Content-Type, Content-Description, Content-Length, Transfer-Encoding
  parser.resetSlices
  while parser.buf[] != ':':
    parser.buf += 1
    parser.aSlice.b += 1
  parser.takeASlice
  parser.buf += 1
  parser.incBSlice
  parser.skipWhiteSpaceAndIncBSlice
  if parser.buf[] == '"':
    parser.buf += 1
    parser.incBSlice
    while parser.buf[] != '"':
      parser.buf += 1
      parser.bSlice.b += 1
    parser.buf += 1
    parser.incBSlice
  else:
    while parser.buf[] != '\c' and (parser.buf + 1)[] != '\l' and parser.buf[] != ';':
      if parser.buf[] == '"':
        parser.buf += 1
        parser.incBSlice
        while parser.buf[] != '"':
          parser.buf += 1
          parser.bSlice.b += 1
        parser.buf += 1
        parser.incBSlice
      else:
        parser.buf += 1
        parser.bSlice.b += 1
  case parser.aStr:
    of "Content-Type":
      echo "parser.dispositionIndex:" & $parser.dispositionIndex
      parser.currentDisposition.contentType = parser.bStr
    of "Transfer-Encoding":
      parser.currentDisposition.transferEncoding = parser.bStr
    of "Content-Description":
      parser.currentDisposition.contentDescription = parser.bStr
    of "Content-Length":
      parser.currentDisposition.contentLength = parser.bStr
    else:
      discard

proc readLine(parser:MultipartParser): Future[int] {.async.} =
  result = await parser.transp.readUntil(parser.src[0].addr, sep = @[byte('\c'),byte('\l')], nbytes = parser.needReadLen)
  parser.buf = parser.src[0].addr

proc parse*(parser:MultipartParser) {.async.} =
  while not parser.transp.atEof():
    case parser.state:
      of boundaryBegin:
        echo "boundaryBegin state"
        parser.read += await parser.readLine
        assert parser.isBoundaryBegin
        parser.skipBeginTok
        parser.skipLineEnd
        parser.state = disposition 
      of disposition:
        # https://www.ietf.org/rfc/rfc1806.txt
        # skip Content-Disposition:
        echo "disposition state"
        parser.tmpRead = await parser.readLine
        parser.read += parser.tmpRead
        echo "tmp:" & $parser.tmpRead
        parser.skipContentDispositionFlag
        parser.skipWhiteSpace
        # skip form-data;
        parser.skipFormDataFlag
        parser.skipWhiteSpace
        var name = parser.getName
        if parser.hasMoreField:
          parser.skipWhiteSpace
          var filename = parser.getFileName
          let filepath = getTempDir() / $genOid()
          parser.dispositions.add ContentDisposition(kind:file,name:name,filename:filename,filepath:filepath,file:openFileStream( filepath,fmWrite ) )
          echo "filename:",filename
        else:
          parser.dispositions.add ContentDisposition(kind:data,name:name)
        parser.skipLineEnd
        echo "name:",name
        parser.tmpRead = await parser.readLine
        parser.read += parser.tmpRead
        echo "tmp:" & $parser.tmpRead
        if parser.tmpRead == 2:
          parser.skipLineEnd
          parser.state = contentBegin 
          # content followed
        else:
          # extro meta data
          parser.parseParam()
          parser.skipLineEnd
          while true:
            parser.tmpRead = await parser.readLine
            parser.read += parser.tmpRead
            if parser.tmpRead == 2:
              parser.skipLineEnd
              break
            parser.parseParam()
          parser.skipLineEnd
          echo "extro meta data handled"
          parser.state = contentBegin
      of contentBegin:
        echo "contentBegin state"
        var needReload = false
        block contentReadLoop:
          while true:
            try:
              echo "start readLine"
              parser.tmpRead = await parser.readLine()
              echo "tmp:" & $parser.tmpRead
              parser.read += parser.tmpRead
              echo "end readLine"
              needReload = false
            except AsyncStreamLimitError:
              echo "needReload = true"
              needReload = true
            echo "needReload:" & $needReload
            if needReload == false:
              # read content complete
              if parser.currentDisposition.kind == data:
                parser.currentDisposition.value = cast[string](parser.src[0 ..< parser.tmpRead - 2])
              elif parser.currentDisposition.kind == file:
                parser.currentDisposition.file.writeData(parser.src[0].addr, parser.tmpRead - 2)
              parser.state = contentEnd
              break contentReadLoop 
            else:
              # read partial content
              if parser.currentDisposition.kind == data:
                parser.currentDisposition.value.add cast[string](parser.src[0 ..< parser.tmpRead])
              elif parser.currentDisposition.kind == file:
                parser.currentDisposition.file.writeData(parser.src[0].addr, parser.tmpRead)
            echo "inner loop end"
      of contentEnd:
        echo "contentEnd state"
        if parser.remainLen == parser.boundaryEndLen:
          echo "parser.remainLen == parser.boundaryEndLen"
          parser.state = boundaryEnd
          if parser.currentDisposition.kind == file:
            parser.currentDisposition.file.flush
            parser.currentDisposition.file.close
          break
        parser.tmpRead = await parser.readLine()
        echo "tmp:" & $parser.tmpRead
        parser.read += parser.tmpRead
        if parser.isBoundaryEnd:
          echo "contentEnd isBoundaryEnd"
          if parser.currentDisposition.kind == file:
            parser.currentDisposition.file.flush
            parser.currentDisposition.file.close
          parser.state = boundaryEnd
        elif parser.isBoundaryBegin:
          echo "contentEnd isBoundaryBegin"
          if parser.currentDisposition.kind == file:
            parser.currentDisposition.file.flush
            parser.currentDisposition.file.close
          inc parser.dispositionIndex
          parser.state = disposition
        else:
          echo parser.buf[]
          echo (parser.buf + 3)[]
          echo (parser.buf + 4)[]
      of boundaryEnd:
        echo "boundaryEnd state"
        parser.skipEndTok
        break

when isMainModule:
  let a =  parseBoundary("""multipart/form-data; boundary="---- next message ----"""")
  doAssert a.i != -1 and a.boundary.len > 0
  let b = parseBoundary("""multipart/form-data;boundary=---- next message ----""")
  doAssert b.i != -1 and b.boundary.len > 0