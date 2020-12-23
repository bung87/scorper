
##
## This module implements a stream http multipart parser
## depends on chronos StreamTransport
##
## Copyright (c) 2020 Bung

import streams, os, oids, strformat
import chronos
import parseutils, strutils # parseBoundary
import constant

const ContentDispoitionFlagLen = "Content-Disposition:".len
const FormDataFlagLen = "form-data;".len

type 
  BoundaryMissingError* = object of CatchableError
  BoundaryInvalidError * = object of CatchableError
  LineIncompleteError = object of CatchableError
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
        filename*, filepath*, contentType*, contentDescription*, contentLength*:string
        file:FileStream

proc `$`*(x:ContentDisposition):string =
  if x.kind == data:
    result = fmt"""{{"name":"{x.name}", "value": "{x.value}"}}"""
  elif x.kind == file:
    result = fmt"""{{"name":"{x.name}", "filename":"{x.filename}", "contentType": "{x.contentType}", "filepath": {x.filepath} }}"""

template `+`[T](p: ptr T, off: int): ptr T =
    cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

template `+=`[T](p: ptr T, off: int) =
  p = p + off

template debug(a:varargs[untyped]) =
  when defined(DebugMultipartParser):
    echo a

proc parseBoundary*(line: string): tuple[i:int,boundary:string] = 
  # retrieve boundary from Content-Type
  # consists of 1 to 70 characters 
  # https://tools.ietf.org/html/rfc7578#section-4.1
  const Flag = "multipart/form-data;"
  # const FlagLen = Flag.len
  const BoundaryFlag = "boundary="
  result.i = line.find(Flag)
  if result.i > -1:
    if line.find('"',result.i ) == -1:
      result.i = line.find(BoundaryFlag,result.i )
      if result.i != -1:
        result.boundary = line[result.i + BoundaryFlag.len  ..< line.len]
    else:
      result.i = line.find(BoundaryFlag,result.i )
      if result.i != -1:
        result.boundary = captureBetween(line,'"','"',result.i + BoundaryFlag.len)
  if result.i == -1:
    raise newException(BoundaryMissingError,"Boundary missing")
  elif result.boundary.len == 0 or result.boundary.len > 70:
    raise newException(BoundaryInvalidError,"Boundary invalid")

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

proc remainLen(parser:MultipartParser):int {.inline.} =
  parser.contentLength - parser.read

proc needReadLen(parser: MultipartParser): int {.inline.} =
  min(parser.remainLen, HttpRequestBufferSize)

proc currentDisposition(parser:MultipartParser):ContentDisposition{.inline.} =
  parser.dispositions[parser.dispositionIndex]

proc skipWhiteSpace(parser:MultipartParser) {.inline.} =
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

proc skipContentDispositionFlag(parser:MultipartParser) {.inline.} =
  # Content-Disposition (case senstitive)
  parser.buf += ContentDispoitionFlagLen

proc skipFormDataFlag(parser:MultipartParser) =
  parser.buf += FormDataFlagLen

proc skipLineEnd(parser:MultipartParser) {.inline.} =
  if parser.buf[] == '\c' and (parser.buf + 1)[] == '\l':
    parser.buf += 2

proc skipBeginTok(parser:MultipartParser) {.inline.} =
  parser.buf += parser.boundaryBeginLen

proc validateBoundary(parser:MultipartParser, line: string):bool =
  # https://tools.ietf.org/html/rfc2046#section-5.1
  # NOTE TO IMPLEMENTORS:  Boundary string comparisons must compare the
  # boundary value with the beginning of each candidate line.  An exact
  # match of the entire candidate line is not required; it is sufficient
  # that the boundary appear in its entirety following the CRLF.
  line == parser.boundaryBegin

proc skipEndTok(parser:MultipartParser) {.inline.} =
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

proc incBSlice(parser:MultipartParser, n:int = 1) {.inline.} =
  inc parser.bSlice.a,n
  inc parser.bSlice.b,n

proc resetSlices(parser:MultipartParser) {.inline.} =
  parser.aSlice = default(Slice[int])
  parser.bSlice = default(Slice[int])

proc skipWhiteSpaceAndIncBSlice(parser:MultipartParser) {.inline.} =
  # skip possible whitespace between value's fields
  if parser.buf[] == ' ':
    parser.buf += 1
    parser.incBSlice

proc processName(parser:MultipartParser) {.inline.} =
  # skip name="
  parser.buf += 6
  parser.incBSlice 6
  while parser.buf[] != '"':
    parser.buf += 1
    parser.bSlice.b += 1
  parser.buf += 1

proc hasMoreField(parser:MultipartParser):bool {.inline.} = 
  result = parser.buf[] == ';'
  if result:
    parser.buf += 1

proc processFileName(parser:MultipartParser) =
  # skip filename="
  parser.buf += 10
  parser.incBSlice 10
  while parser.buf[] != '"':
    parser.buf += 1
    parser.bSlice.b += 1
  parser.buf += 1

proc parseParam(parser:MultipartParser){.inline.} =
  # Content-Type, Content-Description, Content-Length, Transfer-Encoding
  debug "dispositionIndex:" & $parser.dispositionIndex
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
      debug parser.currentDisposition.kind
      parser.currentDisposition.contentType = parser.bStr
    of "Content-Description":
      parser.currentDisposition.contentDescription = parser.bStr
    of "Content-Length":
      parser.currentDisposition.contentLength = parser.bStr
    else:
      discard

proc readLine(parser:MultipartParser): Future[int] {.async.} =
  parser.buf = parser.src[0].addr
  when defined(DebugMultipartParser):
    zeroMem(parser.src[0].addr,parser.src.len)
  var needed = parser.needReadLen
  debug "needed:" & $needed
  debug "contentLength:" & $parser.contentLength
  
  var j = 0
  const sep = ['\c','\l']
  while result < needed:
    discard await parser.transp.readOnce(parser.src[result].addr,1)
    if sep[j] == parser.src[result]:
      inc(j)
      if j == len(sep):
        inc result
        break
    else:
      j = 0
    inc result
  if j < 2:
    raise newException(LineIncompleteError,"")

proc readUntilBoundary(parser:MultipartParser): Future[int] {.async.} =
  parser.buf = parser.src[0].addr
  when defined(DebugMultipartParser):
    zeroMem(parser.src[0].addr,parser.src.len)
  var needed = parser.needReadLen
  debug "needed:" & $needed
  debug "contentLength:" & $parser.contentLength
  
  var j = 0
  let sep = "\c\l" &  parser.boundaryBegin
  while result < needed:
    discard await parser.transp.readOnce(parser.src[result].addr,1)
    if sep[j] == parser.src[result]:
      inc(j)
      if j == len(sep):
        inc result
        break
    else:
      j = 0
    inc result
  if j < sep.len:
    raise newException(LineIncompleteError,"")

proc parse*(parser:MultipartParser) {.async.} =
  while not parser.transp.atEof():
    case parser.state:
      of boundaryBegin:
        debug "boundaryBegin state"
        parser.read += await parser.readLine
        assert parser.isBoundaryBegin
        parser.skipBeginTok
        parser.skipLineEnd
        parser.state = disposition 
      of disposition:
        # https://www.ietf.org/rfc/rfc1806.txt
        # skip Content-Disposition:
        debug "disposition state"
        parser.tmpRead = await parser.readLine
        parser.read += parser.tmpRead
        debug "tmp:" & $parser.tmpRead
        parser.resetSlices
        parser.skipContentDispositionFlag
        parser.incBSlice ContentDispoitionFlagLen
        parser.skipWhiteSpaceAndIncBSlice
        # skip form-data;
        parser.skipFormDataFlag
        parser.incBSlice FormDataFlagLen
        parser.skipWhiteSpaceAndIncBSlice
        parser.processName
        if parser.hasMoreField:
          var disposition = ContentDisposition(kind:file)
          disposition.name = parser.bStr
          parser.incBSlice # for end quote
          parser.bSlice.a = parser.bSlice.b
          parser.incBSlice # for ;
          parser.incBSlice # next pos
          parser.skipWhiteSpaceAndIncBSlice
          parser.processFileName
          disposition.filename = parser.bStr
          disposition.filepath = getTempDir() / $genOid()
          disposition.file = openFileStream( disposition.filepath ,fmWrite )
          parser.dispositions.add disposition
        else:
          parser.dispositions.add ContentDisposition(kind:data,name: parser.bStr)
        parser.skipLineEnd
        parser.tmpRead = await parser.readLine
        parser.read += parser.tmpRead
        debug "tmp:" & $parser.tmpRead
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
              debug "extro meta data skipLineEnd"
              break
            parser.parseParam()
          parser.skipLineEnd
          debug "extro meta data handled"
          parser.state = contentBegin
      of contentBegin:
        debug "contentBegin state"
        var needReload = false
        block contentReadLoop:
          while true:
            try:
              debug "start readLine"
              parser.tmpRead = await parser.readUntilBoundary()
              needReload = false
            except LineIncompleteError:
              debug "LineIncompleteError parser.needReadLen:" & $parser.needReadLen
              parser.tmpRead = parser.needReadLen
              needReload = true
            parser.read += parser.tmpRead
            if parser.remainLen == 0:
              needReload = false
            debug "read:" & $parser.read
            debug "needReload:" & $needReload
            debug "contentReadLoop tmp:" & $parser.tmpRead
            debug "end readLine"
            if needReload == false:
              # read content complete
              debug "read content complete"
              if parser.currentDisposition.kind == data:
                parser.currentDisposition.value = cast[string](parser.src[0 ..< parser.tmpRead - 2 - parser.boundaryBeginLen])
              elif parser.currentDisposition.kind == file:
                parser.currentDisposition.file.writeData(parser.src[0].addr, parser.tmpRead - 2 - parser.boundaryBeginLen)
              parser.buf = parser.src[parser.tmpRead - 1].addr
              parser.state = contentEnd
              break contentReadLoop 
            else:
              # read partial content
              debug "read partial content"
              
              if parser.currentDisposition.kind == data:
                parser.currentDisposition.value.add cast[string](parser.src[0 ..< parser.tmpRead])
              elif parser.currentDisposition.kind == file:
                parser.currentDisposition.file.writeData(parser.src[0].addr, parser.tmpRead)
              parser.buf = parser.src[parser.tmpRead - 1].addr
            debug "inner loop end"
      of contentEnd:
        debug "contentEnd state"
        debug "content length:" & $ parser.contentLength
        debug "remain length:" & $ parser.remainLen
        if parser.remainLen == parser.boundaryEndLen:
          debug "parser.remainLen == parser.boundaryEndLen"
          parser.state = boundaryEnd
          if parser.currentDisposition.kind == file:
            parser.currentDisposition.file.flush
            parser.currentDisposition.file.close
          break
        if parser.remainLen != 0:
          try:
            parser.tmpRead = await parser.readLine()
          except LineIncompleteError:
            if parser.currentDisposition.kind == file:
              parser.currentDisposition.file.flush
              parser.currentDisposition.file.close
            parser.state = boundaryEnd
            continue
          debug "contentEnd tmp:" & $parser.tmpRead
          parser.read += parser.tmpRead
          inc parser.dispositionIndex
          parser.state = disposition
          continue

        if parser.isBoundaryEnd:
          debug "contentEnd isBoundaryEnd"
          if parser.currentDisposition.kind == file:
            parser.currentDisposition.file.flush
            parser.currentDisposition.file.close
          parser.state = boundaryEnd
        elif parser.isBoundaryBegin:
          debug "contentEnd isBoundaryBegin"
          if parser.currentDisposition.kind == file:
            parser.currentDisposition.file.flush
            parser.currentDisposition.file.close
          inc parser.dispositionIndex
          parser.state = disposition
        else:
          debug parser.buf[]
          debug (parser.buf + 3)[]
          debug (parser.buf + 4)[]
          break
      of boundaryEnd:
        debug "boundaryEnd state"
        parser.skipEndTok
        break

when isMainModule:
  let a =  parseBoundary("""multipart/form-data; boundary="---- next message ----"""")
  doAssert a.i != -1 and a.boundary.len > 0
  let b = parseBoundary("""multipart/form-data;boundary=---- next message ----""")
  doAssert b.i != -1 and b.boundary.len > 0