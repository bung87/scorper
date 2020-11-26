
import streams, os, oids, strformat
import chronos
import parseutils, strutils # parseBoundary
import constant

type 
  MultipartState* = enum
    beginTok, endTok,contentEnd, disposition, content
  MultipartParser* = ref object
    beginTok, endTok: string
    beginTokLen, endTokLen: int
    state*: MultipartState
    dispositionIndex:int
    contentLength:int
    transp:StreamTransport
    tmpRead:int
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
        filename*,contentType*,transferEncoding*:string
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
  result.state = beginTok
  result.beginTok = "--" & boundary
  result.endTok = "--" & boundary & "--"
  result.beginTokLen = result.beginTok.len
  result.endTokLen = result.endTok.len
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

proc isBegin(parser:MultipartParser):bool{.inline.} =
  result = true
  for i in 0 ..< parser.beginTokLen:
    if (parser.buf + i)[] != parser.beginTok[i]:
      return false

proc isEnd(parser:MultipartParser):bool {.inline.}=
  result = true
  for i in 0 ..< parser.endTokLen:
    if (parser.buf + i)[] != parser.endTok[i]:
      return false

proc skipContentDispositionFlag(parser:MultipartParser) =
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
  parser.buf += parser.beginTokLen

proc validateBoundary(parser:MultipartParser, line: string):bool =
  line == parser.beginTok

proc skipEndTok(parser:MultipartParser) =
  parser.buf += parser.endTokLen

proc parseParam(parser:MultipartParser){.inline.} =
  var name:string
  while parser.buf[] != ':':
    name.add parser.buf[]
    parser.buf += 1
  parser.buf += 1
  echo "param name:" & name
  parser.skipWhiteSpace
  var value:string
  if parser.buf[] == '"':
    parser.buf += 1
    while parser.buf[] != '"':
      value.add parser.buf[]
      parser.buf += 1
    parser.buf += 1
  else:
    while parser.buf[] != '\c' and (parser.buf + 1)[] != '\l' and parser.buf[] != ';':
      if parser.buf[] == '"':
        parser.buf += 1
        while parser.buf[] != '"':
          value.add parser.buf[]
          parser.buf += 1
        parser.buf += 1
      else:
        value.add parser.buf[]
        parser.buf += 1
  echo "value:" & value
  case name:
    of "Content-Type":
      echo "parser.dispositionIndex:" & $parser.dispositionIndex
      parser.currentDisposition.contentType = value
    of "Transfer-Encoding":
      parser.currentDisposition.transferEncoding = value
    else:
      discard

proc readLine(parser:MultipartParser): Future[int] {.async.} =
  result = await parser.transp.readUntil(parser.src[0].addr, sep = @[byte('\c'),byte('\l')], nbytes = parser.needReadLen)
  parser.buf = parser.src[0].addr

proc parse*(parser:MultipartParser) {.async.} =
  while not parser.transp.atEof():
    case parser.state:
      of beginTok:
        echo "beginTok state"
        parser.read += await parser.readLine
        assert parser.isBegin
        parser.skipBeginTok
        parser.skipLineEnd
        parser.state = disposition 
      of disposition:
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
          parser.state = content 
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
          parser.state = content
      of content:
        echo "content state"
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
            while true: # handle char
              if parser.isEnd:
                echo "handle char isEnd"
                if parser.currentDisposition.kind == file:
                  parser.currentDisposition.file.flush
                  parser.currentDisposition.file.close
                parser.state = endTok
                break contentReadLoop
              elif parser.isBegin:
                echo "handle char isBegin"
                if parser.currentDisposition.kind == file:
                  parser.currentDisposition.file.flush
                  parser.currentDisposition.file.close
                inc parser.dispositionIndex
                parser.state = disposition
                break contentReadLoop
              elif parser.buf[] == '\c' and  (parser.buf + 1)[] == '\l':
                # content end
                parser.skipLineEnd
                echo parser.dispositions
                echo "content end"
                parser.state = contentEnd
                break contentReadLoop 
              else:
                if parser.currentDisposition.kind == data:
                  parser.currentDisposition.value.add parser.buf[]
                  parser.buf += 1
                elif parser.currentDisposition.kind == file:
                  parser.currentDisposition.file.write(parser.buf[])
                  parser.buf += 1
            echo "inner loop end"
      of contentEnd:
        echo "contentEnd state"
        if parser.remainLen == parser.endTokLen:
          parser.state = endTok
          if parser.currentDisposition.kind == file:
            # parser.currentDisposition.file.flush
            parser.currentDisposition.file.close
          break
        parser.tmpRead = await parser.readLine()
        echo "tmp:" & $parser.tmpRead
        parser.read += parser.tmpRead
        if parser.isEnd:
          echo "contentEnd isEnd"
          if parser.currentDisposition.kind == file:
            parser.currentDisposition.file.flush
            parser.currentDisposition.file.close
          parser.state = endTok
        elif parser.isBegin:
          echo "contentEnd isBegin"
          if parser.currentDisposition.kind == file:
            parser.currentDisposition.file.flush
            parser.currentDisposition.file.close
          inc parser.dispositionIndex
          parser.state = disposition
        else:
          echo parser.buf[]
          echo (parser.buf + 3)[]
          echo (parser.buf + 4)[]
      of endTok:
        echo "endTok state"
        parser.skipEndTok
        break

when isMainModule:
  let a =  parseBoundary("""multipart/form-data; boundary="---- next message ----"""")
  doAssert a.i != -1 and a.boundary.len > 0
  let b = parseBoundary("""multipart/form-data;boundary=---- next message ----""")
  doAssert b.i != -1 and b.boundary.len > 0