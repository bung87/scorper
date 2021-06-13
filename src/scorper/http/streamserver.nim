
##
## This module implements a stream http server
## depends on chronos
##
## Copyright (c) 2020 Bung

import chronos
import mofuparser, parseutils, strutils
import npeg/codegen
import urlencodedparser, multipartparser, acceptparser, rangeparser, oids, httpform, httpdate, httpcore, urlly, router,
    netunit, mimetypes, httperror
include constant
import std / [os, streams, options, strformat, json, sequtils, macros]
import rx_nim
from std/times import Time, parseTime, utc, `<`, now, `$`
import zippy

when defined(ssl):
  import chronos / streams/tlsstream
else:
  type
    TLSVersion* {.pure.} = enum
      TLS10 = 0x0301, TLS11 = 0x0302, TLS12 = 0x0303

    TLSFlags* {.pure.} = enum
      NoVerifyHost,         # Client: Skip remote certificate check
      NoVerifyServerName,   # Client: Skip Server Name Indication (SNI) check
      EnforceServerPref,    # Server: Enforce server preferences
      NoRenegotiation,      # Server: Reject renegotiations requests
      TolerateNoClientAuth, # Server: Disable strict client authentication
      FailOnAlpnMismatch    # Server: Fail on application protocol mismatch
    TLSSessionCache* = ref object
      # storage: seq[byte]
      # context: SslSessionCacheLru
import chronos / sendfile
import exts/resumable
import results

when defined(windows):
  import winlean
const MethodNeedsBody = {HttpPost, HttpPut, HttpConnect, HttpPatch}

type
  Request* = ref object
    meth*: HttpMethod
    headers*: HttpHeaders
    protocol*: tuple[major, minor: int]
    url*: Url
    path*: string              # http req path
    hostname*: string
    ip*: string
    params*: Table[string, string]
    query*: seq[(string, string)]
    transp: StreamTransport
    buf: array[HttpRequestBufferSize, char]
    contentLength: BiggestUInt # as RFC no limit
    contentType: string
    server: Scorper
    prefix: string
    parsedJson: Option[JsonNode]
    parsedForm: Option[Form]
    parsed: bool               # indicate http body parsed
    rawBody: Option[string]
    responded: bool
    when defined(ssl):
      tlsStream: TLSAsyncStream
    reader: AsyncStreamReader
    writer: AsyncStreamWriter

  ScorperCallback* = proc (req: Request): Future[void] {.closure, gcsafe.}
  Scorper* = ref object of StreamServer
    callback: ScorperCallback
    maxBody: int
    router: Router[ScorperCallback]
    mimeDb: MimeDB
    httpParser: MofuParser
    privAccpetParser: Parser[char, seq[tuple[mime: string, q: float, extro: int, typScore: int]]]
    when defined(ssl):
      secureFlags: set[TLSFlags]
      tlsPrivateKey: TLSPrivateKey
      tlsCertificate: TLSCertificate
      tlsMinVersion: TLSVersion
      tlsMaxVersion: TLSVersion
    isSecurity: bool
    logSub: Subject[string]
  ResumableResult* = Result[Resumable, string]

proc `$`*(r: Request): string =
  var j = newJObject()
  j["url"] = % $r.url
  j["method"] = % $r.meth
  j["hostname"] = % r.hostname
  j["headers"] = %* r.headers.table
  result = $j

func len*(r: Request): BiggestUInt = r.contentLength

proc formatCommon*(r: Request, status: HttpCode, size: int): string =
  # LogFormat "%h %l %u %t \"%r\" %>s %b" common
  # LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
  let remoteUser = os.getEnv("REMOTE_USER", "-")
  result = fmt"""{r.hostname} - {remoteUser} {$now()} "{r.meth} {r.path} HTTP/{r.protocol.major}.{r.protocol.minor}" {status} {size}"""

proc genericHeaders(headers = newHttpHeaders()): lent HttpHeaders {.tags: [TimeEffect].} =
  ## genericHeaders contains Date,X-Frame-Options
  # Date: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.18
  headers.Date httpDate()
  headers.XFrameOptions "SAMEORIGIN"
  when HttpServer.len > 0:
    headers.Server HttpServer
  return headers

func getExt*(req: Request, mime: string): string =
  result = req.server.mimeDb.getExt(mime, default = "")

func getMimetype*(req: Request, ext: string): string =
  result = req.server.mimeDb.getMimetype(ext, default = "")

macro acceptMime*(req: Request, ext: untyped, headers: HttpHeaders, body: untyped) =
  ## Responds to the req respect client's accept
  ## Automatically set headers content type to corresponding accept mime, when none matched, change it to other mime yourself
  result = quote do:
    var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
    let accept: string = req.headers.getOrDefault("accept", @["text/plain"].HttpHeaderValues)
    var r: MatchResult[char]
    try:
      r = req.server.privAccpetParser.match(accept, mimes)
    except Exception as err:
      await req.respError(Http500, err.msg, headers)
      return
    var ext {.inject.}: string
    if r.ok:
      for item in mimes.mitems:
        ext = req.getExt(item.mime)
        headers.ContentType item.mime
        `body`
    else:
      `body`

func gzip*(req: Request): bool = GzipEnable and req.headers.hasKey("Accept-Encoding") and
    string(req.headers["Accept-Encoding"]).contains("gzip")

template devLog(req: Request, content: untyped) =
  when not defined(release):
    try:
      req.server.logSub.next(`content`)
    except:
      discard

proc resp*(req: Request, content: sink string,
              headers: HttpHeaders = newHttpHeaders(), code: HttpCode = Http200): Future[void] {.async.} =
  ## Responds to the req with the specified ``HttpCode``, headers and
  ## content.
  # If the headers did not contain a Content-Length use our own
  if req.responded == true:
    return
  let gzip = req.gzip()
  let originalLen = content.len
  let needCompress = gzip and originalLen >= gzipMinLength
  var ctn: string
  var length: int
  if needCompress:
    headers.ContentEncoding "gzip"
    ctn = compress(content, BestSpeed, dfGzip)
    length = ctn.len
  else:
    shallowCopy(ctn, content)
    length = originalLen
  let flen = $length
  headers.hasKeyOrPut("Content-Length"):
    flen
  headers.hasKeyOrPut("Date"):
    httpDate()
  when HttpServer.len > 0:
    headers.hasKeyOrPut("Server"):
      HttpServer
  var msg = generateHeaders(headers, code)
  msg.add(ctn)
  await req.writer.write(msg)
  req.devLog(req.formatCommon(code, length))
  req.responded = true

proc respError*(req: Request, code: HttpCode, content: sink string, headers = newHttpHeaders()): Future[
    void] {.async.} =
  ## Responds to the req with the specified ``HttpCode``.
  if req.responded == true:
    return
  var headers = genericHeaders(headers)
  let gzip = req.gzip()
  let originalLen = content.len
  let needCompress = gzip and originalLen >= gzipMinLength
  var ctn: string
  var length: int
  if needCompress:
    headers.ContentEncoding "gzip"
    ctn = compress(content, BestSpeed, dfGzip)
    length = ctn.len
  else:
    shallowCopy(ctn, content)
    length = originalLen
  let flen = $length
  headers.hasKeyOrPut("Content-Length"):
    flen
  var msg = generateHeaders(headers, code)
  msg.add(ctn)
  await req.writer.write(msg)
  req.devLog(req.formatCommon(code, length))
  req.responded = true

proc respError*(req: Request, code: HttpCode, headers = newHttpHeaders()): Future[void] {.async.} =
  ## Responds to the req with the specified ``HttpCode``.
  if req.responded == true:
    return
  var headers = genericHeaders(headers)
  let content = $code
  let gzip = req.gzip()
  let originalLen = content.len
  let needCompress = gzip and originalLen >= gzipMinLength
  var ctn: string
  var length: int
  if needCompress:
    headers.ContentEncoding "gzip"
    ctn = compress(content, BestSpeed, dfGzip)
    length = ctn.len
  else:
    shallowCopy(ctn, content)
    length = originalLen
  let flen = $length
  headers.hasKeyOrPut("Content-Length"):
    flen
  var msg = generateHeaders(headers, code)
  msg.add(content)
  await req.writer.write(msg)
  req.devLog(req.formatCommon(code, length))
  req.responded = true

func pairParam(x: tuple[key: string, value: string]): string =
  result = x[0] & '=' & '"' & x[1] & '"'

proc respBasicAuth*(req: Request, scheme = "Basic", realm = "Scorper", params: seq[tuple[key: string,
    value: string]] = @[], code = Http401): Future[void] {.async.} =
  ## Responds to the req with the specified ``HttpCode``.
  if req.responded == true:
    return
  var headers = genericHeaders()
  let extro = if params.len > 0: "," & params.map(pairParam).join(",") else: ""
  headers.WWWAuthenticate &"{scheme} realm={realm}" & extro
  let msg = generateHeaders(headers, code)
  await req.writer.write(msg)
  req.devLog(req.formatCommon(code, 0))
  req.responded = true

proc respStatus*(req: Request, code: HttpCode, ver = HttpVer11): Future[void] {.async.} =
  if req.responded == true:
    return
  await req.writer.write($ver & " " & $code & "Date: " & httpDate() & CRLF & CRLF)
  req.devLog(req.formatCommon(code, 0))
  req.responded = true

proc respStatus*(req: Request, code: HttpCode, msg: string, ver = HttpVer11): Future[void] {.async.} =
  if req.responded == true:
    return
  await req.writer.write($ver & " " & $code.int & msg & "Date: " & httpDate() & CRLF & CRLF)
  req.devLog(req.formatCommon(code, 0))
  req.responded = true

template writeFileFull(req: Request, file: File, size: int) =
  const bufSize = 8192
  if size < bufSize:
    await req.writer.write(file.readAll)
  else:
    var buf {.noinit.}: array[bufSize, char]
    while true:
      var readBytes = file.readBuffer(buf[0].addr, bufSize)
      await req.writer.write(buf.addr, readBytes)
      if readBytes != bufSize: break

proc writeFile(req: Request, fname: string, size: int): Future[void] {.async.} =
  var handle = 0
  var file: File
  try:
    file = open(fname)
  except Exception as e:
    try:
      req.server.logSub.next(e.msg)
    except Exception:
      discard
    return
  when defined(windows):
    handle = int(getOsFileHandle(file))
  else:
    handle = int(getFileHandle(file))
  if req.server.isSecurity:
    writeFileFull(req, file, size)
  else:
    var s = size
    when compiles(sendfile(req.writer.tsource.fd.FileHandle.int, handle, 0, s)):
      discard sendfile(req.writer.tsource.fd.FileHandle.int, handle, 0, s)
    else:
      writeFileFull(req, file, size)
  close(file)

template writeFileStream(req: Request, fname: string, offset: int, size: int) =
  const bufSize = 8192
  var buf {.noinit.}: array[bufSize, char]
  var totalRead = 0
  let fs = openFileStream(fname, fmRead, bufSize)
  fs.setPosition(offset)
  let rlen = min(size, bufSize)
  while true:
    var readBytes = fs.readData(buf[0].addr, rlen)
    if readBytes == 0:
      break
    await req.writer.write(buf[0].addr, readBytes)
    totalRead.inc readBytes
    if totalRead == rlen:
      break
  fs.close

proc writePartialFile(req: Request, fname: string, ranges: seq[tuple[starts: int, ends: int]], meta: Option[tuple[
    info: FileInfo, headers: HttpHeaders]], boundary: string, mime: string) {.async.} =
  let fullSize = meta.unsafeGet.info.size.int
  var handle = 0
  var file: File
  if not req.server.isSecurity:
    try:
      file = open(fname)
    except Exception as e:
      try:
        req.server.logSub.next(e.msg)
      except Exception:
        discard
      return
    when defined(windows):
      handle = int(getOsFileHandle(file))
    else:
      handle = int(getFileHandle(file))
  for b in ranges:
    await req.writer.write(boundary & CRLF)
    await req.writer.write(fmt"Content-Type: {mime}" & CRLF)
    if b.ends > 0:
      await req.writer.write(fmt"Content-Range: bytes {b.starts}-{b.ends}/{fullSize}" & CRLF & CRLF)
    elif b.ends == 0:
      await req.writer.write(fmt"Content-Range: bytes {b.starts}-{fullSize - 1}/{fullSize}" & CRLF & CRLF)
    else:
      await req.writer.write(fmt"Content-Range: bytes {b.ends}/{fullSize}" & CRLF & CRLF)
    let offset = if b.ends >= 0: b.starts else: fullSize + b.ends
    let size = if b.ends > 0: b.ends - b.starts + 1: elif b.ends == 0: fullSize - b.starts else: abs(b.ends)
    if req.server.isSecurity:
      try:
        writeFileStream(req, fname, offset, size)
      except Exception:
        discard
    else:
      var written = size
      when compiles(sendfile(req.writer.tsource.fd.FileHandle.int, handle, offset, written)):
        let ret = sendfile(req.writer.tsource.fd.FileHandle.int, handle, offset, written)
      else:
        writeFileStream(req, fname, offset, size)
  await req.writer.write(CRLF & boundary & "--")
  if handle != 0:
    close(file)

proc fileGuard(req: Request, filepath: string): Future[Option[FileInfo]] {.async.} =
  # If-Modified-Since: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.25
  # The result of a req having both an If-Modified-Since header field and either an If-Match or an If-Unmodified-Since header fields is undefined by this specification.
  if not fileExists(filepath):
    return none(FileInfo)
  var info: FileInfo
  try:
    info = getFileInfo(filepath)
  except:
    return none(FileInfo)
  if fpOthersRead notin info.permissions:
    await req.respError(Http403)
    return none(FileInfo)
  if req.headers.hasKey("If-Modified-Since"):
    var ifModifiedSince: Time
    try:
      ifModifiedSince = parseTime(req.headers["If-Modified-Since"], HttpDateFormat, utc())
    except:
      await req.respError(Http400)
      return none(FileInfo)
    if info.lastWriteTime == ifModifiedSince:
      await req.respStatus(Http304)
      return none(FileInfo)
  elif req.headers.hasKey("If-Unmodified-Since"):
    var ifUnModifiedSince: Time
    try:
      ifUnModifiedSince = parseTime(req.headers["If-Unmodified-Since"], HttpDateFormat, utc())
    except:
      await req.respError(Http400)
      return none(FileInfo)
    if info.lastWriteTime > ifUnModifiedSince:
      await req.respStatus(Http412)
      return none(FileInfo)
  return some(info)

proc fileMeta(req: Request, filepath: string): Future[Option[tuple[info: FileInfo, headers: HttpHeaders]]]{.async, inline.} =
  let info = await fileGuard(req, filepath)
  if not info.isSome():
    return none(tuple[info: FileInfo, headers: HttpHeaders])
  var size = info.get.size
  var headers = genericHeaders()
  headers.ContentLength $size
  headers.LastModified httpDate(info.get.lastWriteTime)
  return some((info: info.get, headers: headers))

func calcContentLength(ranges: seq[tuple[starts: int, ends: int]], size: int): int =
  for b in ranges:
    if b[1] > 0:
      result = result + b[1] - b[0] + 1
    elif b[1] == 0:
      result = result + size - b[0]
    else:
      result = result + abs(b[1])

proc sendFile*(req: Request, filepath: string, extroHeaders: HttpHeaders = newHttpHeaders()) {.async.} =
  ## send file for display
  # Last-Modified: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29
  var meta = await fileMeta(req, filepath)
  if meta.isNone:
    await req.respError(Http404)
    return
  for key, val in extroHeaders:
    meta.unsafeGet.headers[key] = val
  var (_, _, ext) = splitFile(filepath)
  let mime = req.server.mimeDb.getMimetype(ext)
  let rangeRequest = req.headers.hasKey("Range")
  var parseRangeOk = false
  var ranges = newSeq[tuple[starts: int, ends: int]]()
  if rangeRequest:
    let parser = rangeParser()
    let rng: string = req.headers["Range"]
    var r: MatchResult[char]
    try:
      r = parser.match(rng, ranges)
    except:
      discard
    parseRangeOk = r.ok
  if not rangeRequest or not parseRangeOk:
    meta.unsafeGet.headers.ContentType mime
    var msg = generateHeaders(meta.unsafeGet.headers, Http200)
    await req.writer.write(msg)
    await req.writeFile(filepath, meta.unsafeGet.info.size.int)
    req.devLog(req.formatCommon(Http200, meta.unsafeGet.info.size.int))
  else:
    let boundary = "--" & $genOid()
    meta.unsafeGet.headers.ContentType "multipart/byteranges; " & boundary
    var contentLength = calcContentLength(ranges, meta.unsafeGet.info.size.int)
    for b in ranges:
      contentLength = contentLength + len(boundary & CRLF)
      contentLength = contentLength + len(fmt"Content-Type: {mime}" & CRLF)
      if b.ends > 0:
        contentLength = contentLength + len(fmt"Content-Range: bytes {b.starts}-{b.ends}/{meta.unsafeGet.info.size}" &
            CRLF & CRLF)
      elif b.ends == 0:
        contentLength = contentLength + len(fmt"Content-Range: bytes {b.starts}-{meta.unsafeGet.info.size - 1}/{meta.unsafeGet.info.size}" &
            CRLF & CRLF)
      else:
        contentLength = contentLength + len(fmt"Content-Range: bytes {b.ends}/{meta.unsafeGet.info.size}" & CRLF & CRLF)
      contentLength = contentLength + len(CRLF & boundary & "--")
      meta.unsafeGet.headers.ContentLength $contentLength
      var msg = generateHeaders(meta.unsafeGet.headers, Http206)
      await req.writer.write(msg)
      await req.writePartialFile(filepath, ranges, meta, boundary, mime)
      req.devLog(req.formatCommon(Http206, contentLength))

proc sendDownload*(req: Request, filepath: string) {.async.} =
  ## send file directly without mime type , downloaded file name same as original
  # Last-Modified: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29
  var meta = await fileMeta(req, filepath)
  if meta.isNone:
    await req.respError(Http404)
    return
  meta.unsafeGet.headers.ContentType "application/x-download"
  var msg = generateHeaders(meta.unsafeGet.headers, Http200)
  await req.writer.write(msg)
  await req.writeFile(filepath, meta.unsafeGet.info.size.int)
  req.devLog(req.formatCommon(Http200, meta.unsafeGet.info.size.int))
  req.responded = true

proc sendAttachment*(req: Request, filepath: string, asName: string = "") {.async.} =
  let filename = if asName.len == 0: filepath.extractFilename else: asName
  let encodedFilename = &"filename*=UTF-8''{encodeUrlComponent(filename)}"
  let extroHeaders = newHttpHeaders({
    "Content-Disposition": &"""attachment;filename="{filename}";{encodedFilename}"""
  })
  await sendFile(req, filepath, extroHeaders)
  req.responded = true

proc hasSuffix(s: string): bool =
  let sLen = s.len - 1
  var i = sLen
  while i != 0:
    if s[i] == '.':
      return true
    dec i

proc serveStatic*(req: Request) {.async.} =
  ## Relys on `StaticDir` environment variable
  if req.meth != HttpGet and req.meth != HttpHead:
    await req.respError(Http405)
    return
  var relPath: string
  try:
    relPath = req.url.path.relativePath(req.prefix)
  except:
    discard
  if not hasSuffix(relPath):
    relPath = relPath / "index.html"
  let absPath = absolutePath(os.getEnv("StaticDir") / relPath)
  if not absPath.fileExists:
    await req.respError(Http404)
    return
  if req.meth == HttpHead:
    var meta = await fileMeta(req, absPath)
    if meta.isNone:
      await req.respError(Http404)
      return
    var (_, _, ext) = splitFile(absPath)
    let mime = req.server.mimeDb.getMimetype(ext)
    meta.unsafeGet.headers.ContentType mime
    meta.unsafeGet.headers.AcceptRanges "bytes"
    var msg = generateHeaders(meta.unsafeGet.headers, Http200)
    discard await req.transp.write(msg)
    req.responded = true
    return
  await req.sendFile(absPath)
  req.responded = true


proc json*(req: Request): Future[JsonNode] {.async.} =
  if req.parsedJson.isSome:
    return req.parsedJson.unSafeGet
  var str: string
  result = newJNull()
  try:
    str = await req.reader.readLine(limit = req.contentLength.int)
  except AsyncStreamIncompleteError as e:
    await req.respStatus(Http400, ContentLengthMismatch)
    req.parsedJson = some(result)
    req.parsed = true
    return result
  try:
    result = parseJson(str)
  except CatchableError as e:
    raise newHttpError(Http400, e.msg)
  except Exception as e:
    raise newHttpError(Http400, e.msg)
  req.parsedJson = some(result)
  req.parsed = true

proc body*(req: Request): Future[string] {.async.} =
  if req.rawBody.isSome:
    return req.rawBody.unSafeGet
  result = ""
  try:
    result = await req.reader.readLine(limit = req.contentLength.int)
  except AsyncStreamIncompleteError as e:
    await req.respStatus(Http400, ContentLengthMismatch)
  req.rawBody = some(result)
  req.parsed = true

proc stream*(req: Request): AsyncStreamReader =
  doAssert req.transp.closed == false
  req.reader

proc form*(req: Request): Future[Form] {.async.} =
  if req.parsedForm.isSome:
    return req.parsedForm.unSafeGet
  result = newForm()
  case req.contentType:
    of "application/x-www-form-urlencoded":
      var parser = newUrlEncodedParser(req.transp, req.buf.addr, req.contentLength.int)
      var parsed = await parser.parse()
      for (key, value) in parsed:
        let v = if value.len > 0: decodeUrlComponent(value) else: ""
        let k = decodeUrlComponent key
        result.data.add ContentDisposition(kind: ContentDispositionKind.data, name: k, value: v)
    else:
      if req.contentType.len > 0:
        var parsed: tuple[i: int, boundary: string]
        try:
          parsed = parseBoundary(req.contentType)
        except BoundaryMissingError as e:
          await req.respError(Http400, e.msg)
          return
        except BoundaryInvalidError as e:
          await req.respError(Http400, e.msg)
          return
        var parser = newMultipartParser(parsed.boundary, req.transp, req.buf.addr, req.contentLength.int)
        try:
          await parser.parse()
        except BodyIncompleteError as e:
          await req.respError(Http400, e.msg)
          return
        if parser.state == boundaryEnd:
          for disp in parser.dispositions:
            if disp.kind == ContentDispositionKind.data:
              result.data.add disp
            elif disp.kind == ContentDispositionKind.file:
              result.files.add disp
        else:
          try:
            req.server.logSub.next("form parse error: " & $parser.state)
          except:
            discard
      else:
        discard
  req.parsedForm = some(result)
  req.parsed = true

proc postCheck(req: Request): Future[int]{.async, inline.} =
  if req.meth in MethodNeedsBody and req.parsed == false:
    result = await req.reader.consume(req.contentLength.int)

proc defaultErrorHandle(req: Request, err: ref Exception | HttpError; headers = newHttpHeaders()){.async, raises: [].} =
  if req.responded:
    return
  let code = when err is HttpError: err.code.HttpCode else: Http500 #
  acceptMime(req, ext, headers):
    case ext
    of "json":
      var s: string
      toUgly(s, %* {"error": err.msg})
      await req.respError(code, s, headers)
    of "js":
      let cbName: string = req.query["callback"]
      var s: string
      toUgly(s, %* {"error": err.msg})
      await req.respError(code, fmt"""{cbName}({s});""", headers)
    of "html": await req.respError(code, err.msg, headers)
    of "txt": await req.respError(code, err.msg, headers)
    else:
      headers.ContentType "text/plain"
      await req.respError(Http400, err.msg, headers)

template tryHandle(body: untyped, keep: var bool) =
  try:
    await wait(body, TimeOut.seconds)
  except AsyncTimeoutError:
    if not req.responded:
      let err = newHttpError(408.HttpCode)
      var headers = {"Connection": "close"}.newHttpHeaders()
      await req.defaultErrorHandle(err, headers)
      keep = false
  except HttpError as err:
    if not req.responded:
      await req.defaultErrorHandle(err)
  except:
    if not req.responded:
      let err = getCurrentException()
      await req.defaultErrorHandle(err)

proc processRequest(
  scorper: Scorper,
  req: Request,
): Future[bool] {.async.} =
  req.responded = false
  req.parsed = false
  req.parsedJson = none(JsonNode)
  req.parsedForm = none(Form)
  req.headers.clear()
  # receivce untill http header end
  # note: headers field name is case-insensitive, field value is case sensitive
  const HeaderSep = @[byte('\c'), byte('\L'), byte('\c'), byte('\L')]
  var count: int
  try:
    count = await req.reader.readUntil(req.buf[0].addr, len(req.buf), sep = HeaderSep)
  except AsyncStreamIncompleteError:
    return true
  except AsyncStreamLimitError:
    await req.respStatus(Http400, BufferLimitExceeded)
    return false
  except AsyncStreamError as e:
    await req.respStatus(Http400, e.msg)
    return false
  # Headers
  let headerEnd = req.server.httpParser.parseHeader(addr req.buf[0], req.buf.len)
  assert headerEnd != -1
  if headerEnd == -1:
    await req.respError(Http400)
    return true
  req.server.httpParser.toHttpHeaders(req.headers)
  case req.server.httpParser.getMethod
    of "GET": req.meth = HttpGet
    of "POST": req.meth = HttpPost
    of "HEAD": req.meth = HttpHead
    of "PUT": req.meth = HttpPut
    of "DELETE": req.meth = HttpDelete
    of "PATCH": req.meth = HttpPatch
    of "OPTIONS": req.meth = HttpOptions
    of "CONNECT": req.meth = HttpConnect
    of "TRACE": req.meth = HttpTrace
    else:
      await req.respError(Http501)
      return true

  req.path = req.server.httpParser.getPath()
  try:
    req.url = parseUrl("http://" & (if req.server.isSecurity: "s" else: "") & req.hostname & req.path)[]
  except ValueError as e:
    try:
      req.server.logSub.next(e.msg)
    except:
      discard
    asyncSpawn req.respError(Http400)
    return true
  case req.server.httpParser.major[]:
    of '1':
      req.protocol.major = 1
    of '2':
      req.protocol.major = 2
    else:
      discard
  case req.server.httpParser.minor[]:
    of '0':
      req.protocol.minor = 0
    of '1':
      req.protocol.minor = 1
    else:
      discard
  if req.protocol == HttpVer20:
    await req.respStatus(Http505)
    return false

  if req.meth == HttpPost:
    # Check for Expect header
    if req.headers.hasKey("Expect"):
      if "100-continue" in req.headers["Expect"]:
        await req.respStatus(Http400)
      else:
        await req.respStatus(Http417)

  # Read the body
  # - Check for Content-length header
  if unlikely(req.meth in MethodNeedsBody):
    if req.headers.hasKey("Content-Length"):
      try:
        discard parseBiggestUInt(req.headers["Content-Length"], req.contentLength)
      except ValueError:
        await req.respStatus(Http400, "Invalid Content-Length.")
        return true
      if req.contentLength.int > scorper.maxBody:
        await req.respStatus(Http413)
        return false
      if req.headers.hasKey("Content-Type"):
        req.contentType = req.headers["Content-Type"]
    else:
      await req.respStatus(Http411)
      return true
  # Call the user's callback.
  var keep = true
  if scorper.callback != nil:
    shallowCopy(req.query, req.url.query)
    tryHandle(scorper.callback(req), keep)
    if not keep:
      return false
    discard await postCheck(req)
  elif scorper.router != nil:
    let matched = scorper.router.match($req.meth, req.url.path)
    if matched.success:
      req.params = matched.route.params[]
      shallowCopy(req.query, req.url.query)
      req.prefix = matched.route.prefix
      tryHandle(matched.handler(req), keep)
      if not keep:
        return false
      discard await postCheck(req)
    else:
      await req.respError(Http404)

  if "upgrade" in req.headers.getOrDefault("connection"):
    return false

  # The req has been served, from this point on returning `true` means the
  # connection will not be closed and will be kept in the connection pool.

  # Persistent connections
  if (req.protocol == HttpVer11 and
      cmpIgnoreCase(req.headers.getOrDefault("connection"), "close") != 0) or
     (req.protocol == HttpVer10 and
      cmpIgnoreCase(req.headers.getOrDefault("connection"), "keep-alive") == 0):
    # In HTTP 1.1 we assume that connection is persistent. Unless connection
    # header states otherwise.
    # In HTTP 1.0 we assume that the connection should not be persistent.
    # Unless the connection header states otherwise.
    return true
  else:
    return false

proc processClient(server: StreamServer, transp: StreamTransport) {.async.} =
  var req = Request()
  shallowCopy(req.server, cast[Scorper](server))
  req.headers = newHttpHeaders()
  shallowCopy(req.transp, transp)
  try:
    req.hostname = $req.transp.localAddress
  except TransportError:
    discard
  try:
    req.ip = $req.transp.remoteAddress
  except TransportError:
    discard

  when defined(ssl):
    if req.server.isSecurity:
      req.tlsStream =
        newTLSServerAsyncStream(req.transp.newAsyncStreamReader, req.transp.newAsyncStreamWriter,
                                req.server.tlsPrivateKey,
                                req.server.tlsCertificate,
                                minVersion = req.server.tlsMinVersion,
                                maxVersion = req.server.tlsMaxVersion,
                                flags = req.server.secureFlags)
      req.reader = req.tlsStream.reader
      req.writer = req.tlsStream.writer
      await handshake(req.tlsStream)
    else:
      req.reader = req.transp.newAsyncStreamReader
      req.writer = req.transp.newAsyncStreamWriter
  else:
    req.reader = req.transp.newAsyncStreamReader
    req.writer = req.transp.newAsyncStreamWriter
  while not transp.atEof():
    let retry = await processRequest(req.server, req)
    if not retry:
      await req.reader.closeWait
      await req.writer.closeWait
      await transp.closeWait
      break

proc logSubOnNext(v: string) =
  echo v

template initSecurityScorper(scorper: var Scorper; secureFlags: set[TLSFlags]; privateKey, certificate: string;
    tlsMinVersion, tlsMaxVersion: TLSVersion) =
  scorper.isSecurity = true
  scorper.secureFlags = secureFlags
  scorper.tlsPrivateKey = TLSPrivateKey.init(privateKey)
  scorper.tlsCertificate = TLSCertificate.init(certificate)
  scorper.tlsMinVersion = tlsMinVersion
  scorper.tlsMaxVersion = tlsMaxVersion

proc newScorperMimetypes(): MimeDB {.inline.} =
  result = newMimetypes()
  result.register(ext = "jsonp", mimetype = "application/javascript")
  return result

template initScorper(server: Scorper) =
  server.privAccpetParser = accpetParser()
  server.httpParser = MofuParser()
  server.logSub = subject[string]()
  if server.router != nil:
    server.router.compress()
  when not defined(release):
    try:
      discard server.logSub.subscribe logSubOnNext
    except:
      discard
  try:
    server.logSub.next("Scorper serve at http" & (if isSecurity: "s" else: "") & "://" & $server.local)
  except:
    discard

proc serve*(address: string,
            callback: ScorperCallback,
            flags: set[ServerFlags] = {ReuseAddr},
            maxBody = 8.Mb,
            isSecurity = false,
            privateKey: string = "",
            certificate: string = "",
            secureFlags: set[TLSFlags] = {},
            tlsMinVersion = TLSVersion.TLS11,
            tlsMaxVersion = TLSVersion.TLS12,
            cache: TLSSessionCache = nil,
            ) {.async.} =
  var server = Scorper()
  server.mimeDb = newScorperMimetypes()
  server.callback = callback
  server.maxBody = maxBody
  let address = initTAddress(address)
  server = cast[Scorper](createStreamServer(address, processClient, flags, child = cast[StreamServer](server)))
  server.initScorper()
  when defined(ssl):
    if isSecurity:
      server.initSecurityScorper(secureFlags, privateKey, certificate, tlsMinVersion, tlsMaxVersion)
  server.start()

  await server.join()

proc setHandler*(self: Scorper, handler: ScorperCallback) {.raises: [].} =
  self.callback = handler

proc newScorper*(address: string,
                flags: set[ServerFlags] = {ReuseAddr},
                maxBody = 8.Mb,
                isSecurity = false,
                privateKey: string = "",
                certificate: string = "",
                secureFlags: set[TLSFlags] = {},
                tlsMinVersion = TLSVersion.TLS11,
                tlsMaxVersion = TLSVersion.TLS12,
                cache: TLSSessionCache = nil,
                ): Scorper =
  new result
  result.mimeDb = newScorperMimetypes()
  result.maxBody = maxBody
  let address = initTAddress(address)
  result = cast[Scorper](createStreamServer(address, processClient, flags, child = cast[StreamServer](result)))
  result.initScorper()
  when defined(ssl):
    if isSecurity:
      result.initSecurityScorper(secureFlags, privateKey, certificate, tlsMinVersion, tlsMaxVersion)

proc newScorper*(address: string, handler: ScorperCallback | Router[ScorperCallback],
                flags: set[ServerFlags] = {ReuseAddr},
                maxBody = 8.Mb,
                isSecurity = false,
                privateKey: string = "",
                certificate: string = "",
                secureFlags: set[TLSFlags] = {},
                tlsMinVersion = TLSVersion.TLS11,
                tlsMaxVersion = TLSVersion.TLS12,
                cache: TLSSessionCache = nil,
                ): Scorper =
  new result
  result.mimeDb = newScorperMimetypes()
  when handler is ScorperCallback:
    result.callback = handler
  elif handler is Router[ScorperCallback]:
    result.router = handler
  result.maxBody = maxBody
  let address = initTAddress(address)
  result = cast[Scorper](createStreamServer(address, processClient, flags, child = cast[StreamServer](result)))
  result.initScorper()
  when defined(ssl):
    if isSecurity:
      result.initSecurityScorper(secureFlags, privateKey, certificate, tlsMinVersion, tlsMaxVersion)

func isClosed*(server: Scorper): bool =
  server.status = ServerStatus.Closed

proc isComplete*(resumable: Resumable): bool =
  var i: BiggestUInt = 0
  var complete = true
  while i < resumable.totalChunks:
    let chunkKey = resumable.identifier & "." & $(i+1)
    if not fileExists(resumable.tmpDir / chunkKey):
      complete = false
    inc i
  return complete

proc handleResumableUpload*(req: Request; resumableKeys = newResumableKeys()): Future[ResumableResult]{.async.} =
  template resumableParam(key: untyped): untyped =
    req.query[resumableKeys.`key`]

  var resumable: Resumable
  discard parseBiggestUInt(resumableParam(totalChunks), resumable.totalChunks)
  discard parseBiggestUInt(resumableParam(chunkIndex), resumable.chunkIndex)
  discard parseBiggestUInt(resumableParam(currentChunkSize), resumable.currentChunkSize)
  discard parseBiggestUInt(resumableParam(totalSize), resumable.totalSize)
  resumable.identifier = resumableParam(identifier)
  let tmpDir = getTempDir()
  resumable.tmpDir = tmpDir
  let chunkKey = resumable.identifier & "." & $resumable.chunkIndex
  const bufSize = 8192
  var buffer: array[bufSize, char]
  if fileExists(tmpDir / chunkKey):
    await req.respStatus(Http201)
  else:
    let file = open(tmpDir / chunkKey, fmWrite)
    let stream = req.stream()
    var nbytes: int
    var reads: BiggestUInt
    while not stream.atEof():
      if reads == req.len:
        break
      if reads == resumable.currentChunkSize:
        break
      nbytes = await stream.readOnce(buffer[0].addr, buffer.len)
      reads.inc nbytes
      discard file.writeBuffer(buffer[0].addr, nbytes)
    file.close
    await req.respStatus(Http200)

  let complete = resumable.isComplete()
  if complete:

    let file = newFileStream(tmpDir / resumable.identifier, fmWrite)
    var j: BiggestUInt = 0
    while j < resumable.totalChunks:
      let chunkKey = resumable.identifier & "." & $(j+1)
      let s = openFileStream(tmpDir / chunkKey)
      while not s.atEnd:
        let readLen = s.readData(buffer.addr, buffer.len)
        file.writeData(buffer.addr, readLen)
      s.flush
      try:
        s.close
      except:
        discard
      inc j
    file.flush
    try:
      file.close
    except:
      discard
    let filepath = tmpDir / resumable.identifier
    resumable.savePath = filepath
    when not defined(release):
      let fsize = BiggestUInt(getFileSize(filepath))
      assert fileExists(filepath) and fsize == resumable.totalSize
  result.ok resumable


