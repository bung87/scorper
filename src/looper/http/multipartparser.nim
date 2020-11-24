
import httpform
type MultipartState = enum
        beginTok, endTok, disposition, content
type MultipartParser* = ref object
  beginTok, endTok: string
  beginTokLen, endTokLen: int
  state: MultipartState
  dispositionIndex:int
  index:int
  buf: ptr char

template `+`[T](p: ptr T, off: int): ptr T =
    cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

template `+=`[T](p: ptr T, off: int) =
  p = p + off

import parseutils, strutils

proc parseBoundary*(line: string): tuple[i:int,boundary:string] = 
  # retrieve boundary from Content-Type
  const Flag = "multipart/form-data;"
  const FlagLen = Flag.len
  result.i = line.find(Flag)
  if result.i > -1:
    if line.find('"',result.i ) == -1:
      let j = line.find('=',result.i )
      if j != -1:
        result.boundary = line[j + 1 ..< line.len]
    else:
      result.boundary = captureBetween(line,'"','"',result.i + FlagLen)

proc newMultipartParser*(boundary:string): MultipartParser =
  new result
  result.state = beginTok
  result.beginTok = "--" & boundary & "\r\n"
  result.endTok = "--" & boundary & "--\r\n"
  result.beginTokLen = result.beginTok.len
  result.endTokLen = result.endTok.len

proc skipWhiteSpace(parser:MultipartParser) =
  # skip possible whitespace between value's fields
  if parser.buf[] == ' ':
    inc parser.index
    parser.buf += 1

proc isBegin(parser:MultipartParser):bool =
  result = true
  for i in 0 ..< parser.beginTokLen:
    if (parser.buf + i)[] != parser.beginTok[i]:
      return false

proc isEnd(parser:MultipartParser):bool =
  result = true
  for i in 0 ..< parser.endTokLen:
    if (parser.buf + i)[] != parser.endTok[i]:
      return false

proc skipContentDispositionFlag(parser:MultipartParser) =
  const ContentDispoitionFlagLen = "Content-Disposition:".len
  parser.index.inc ContentDispoitionFlagLen
  parser.buf += ContentDispoitionFlagLen

proc skipFormDataFlag(parser:MultipartParser) =
  const FormDataFlagLen = "form-data;".len
  parser.index.inc FormDataFlagLen
  parser.buf += FormDataFlagLen

proc getName(parser:MultipartParser):string =
  # skip name="
  inc parser.index, 6
  parser.buf += 6
  while parser.buf[] != '"':
    result.add parser.buf[]
    inc parser.index
    parser.buf += 1
  inc parser.index
  parser.buf += 1

proc hasMoreField(parser:MultipartParser):bool = 
  result = parser.buf[] == ';'
  if result:
    inc parser.index
    parser.buf += 1

proc getFileName(parser:MultipartParser):string =
  # skip filename="
  inc parser.index, 10
  parser.buf += 10
  while parser.buf[] != '"':
    result.add parser.buf[]
    inc parser.index
    parser.buf += 1
  inc parser.index
  parser.buf += 1

proc skipLineEnd(parser:MultipartParser) =
  inc parser.index,2
  parser.buf += 2

proc skipBeginTok(parser:MultipartParser) =
  parser.index.inc parser.beginTokLen
  parser.buf += parser.beginTokLen

proc skipEndTok(parser:MultipartParser) =
  parser.index.inc parser.endTokLen
  parser.buf += parser.endTokLen

proc parse*(parser:MultipartParser,c:var ptr char,n:int, form: var Form) =
  parser.index = 0
  parser.buf = c
  while parser.index < n:
    case parser.state:
      of beginTok:
        parser.skipBeginTok
        parser.state = disposition 
      of disposition:
        # skip Content-Disposition:
        parser.skipContentDispositionFlag
        parser.skipWhiteSpace
        # skip form-data;
        parser.skipFormDataFlag
        parser.skipWhiteSpace
        var name = parser.getName
        if parser.hasMoreField:
          parser.skipWhiteSpace
          var filename = parser.getFileName
          echo "filename:",filename
        parser.skipLineEnd
        echo "name:",name
        if parser.buf[] == '\c' and  (parser.buf + 1)[] == '\l':
          parser.skipLineEnd
          parser.state = content 
          # content followed
        else:
          # extro meta data
          discard
          # var mhreq = MofuParser(headers:newSeqOfCap[MofuHeader](64))
          # let hdrLen = mhreq.headers.parseHeader(parser.buf, 1024)
          # inc parser.index, hdrLen
          # parser.skipLineEnd
      of content:
        var content:string
        while true:
          if parser.isEnd:
            parser.state = endTok
            break
          elif parser.isBegin:
            parser.skipLineEnd
            parser.state = beginTok
            break
          else:
            content.add parser.buf[]
            parser.buf += 1
        parser.skipLineEnd
        echo "content:",content
      of endTok:
        parser.skipEndTok
        break

when isMainModule:
  let a =  parseBoundary("""multipart/form-data; boundary="---- next message ----"""")
  doAssert a.i != -1 and a.boundary.len > 0
  let b = parseBoundary("""multipart/form-data;boundary=---- next message ----""")
  doAssert b.i != -1 and b.boundary.len > 0