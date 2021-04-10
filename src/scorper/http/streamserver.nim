
##
## This module implements a stream http server
## depends on chronos
##
## Copyright (c) 2020 Bung

import chronos
import mofuparser, parseutils, strutils
import npeg/codegen
import urlencodedparser, multipartparser, acceptparser, rangeparser, oids, httpform, httpdate, httpcore, urlly, router,
    netunit, constant
import std / [os, options, strformat, times, mimetypes, json, sequtils, macros]
import rx_nim
import zippy
when defined(windows):
  import winlean
const MethodNeedsBody = {HttpPost, HttpPut, HttpConnect, HttpPatch}

type
  Request* = ref object
    meth*: HttpMethod
    headers*: HttpHeaders
    protocol*: tuple[major, minor: int]
    url*: Url
    path*: string              # http request path
    hostname*: string
    ip*: string
    params*: Table[string, string]
    query*: seq[(string, string)]
    transp: StreamTransport
    buf: array[HttpRequestBufferSize, char]
    httpParser: MofuParser
    contentLength: BiggestUInt # as RFC no limit
    contentType: string
    server: Scorper
    prefix: string
    parsedJson: Option[JsonNode]
    parsedForm: Option[Form]
    parsed: bool
    rawBody: Option[string]
    privAccpetParser: Parser[char, seq[tuple[mime: string, q: float, extro: int, typScore: int]]]

  AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}
  Scorper* = ref object of StreamServer
    callback: AsyncCallback
    maxBody: int
    router: Router[AsyncCallback]
    mimeDb: MimeDB
    logSub: Subject[string]

proc `$`*(r: Request): string =
  var j = newJObject()
  j["url"] = % $r.url
  j["method"] = % $r.meth
  j["hostname"] = % r.hostname
  j["headers"] = %* r.headers.table
  result = $j

proc formatCommon*(r: Request, status: HttpCode, size: int): string =
  # LogFormat "%h %l %u %t \"%r\" %>s %b" common
  # LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
  let remoteUser = os.getEnv("REMOTE_USER", "-")
  result = fmt"""{r.hostname} - {remoteUser} {$now()} "{r.meth} {r.path} HTTP/{r.protocol.major}.{r.protocol.minor}" {status} {size}"""

proc genericHeaders(): HttpHeaders {.tags: [TimeEffect].} =
  # Date: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.18
  result = newHttpHeaders()
  result["Date"] = httpDate()
  result["X-Frame-Options"] = "SAMEORIGIN"

proc getExt*(req: Request, mime: string): string =
  result = req.server.mimeDb.getExt(mime, default = "")

proc getMimetype*(req: Request, ext: string): string =
  result = req.server.mimeDb.getMimetype(ext, default = "")

macro acceptMime*(req: Request, ext: untyped, headers: HttpHeaders, body: untyped) =
  ## Responds to the request respect client's accept
  ## Automatically set headers content type to corresponding accept mime, when none matched, change it to other mime yourself
  expectLen(body, 1)
  expectKind(body[0], nnkCaseStmt)
  for item in body[0]:
    if item.kind in {nnkOfBranch, nnkElifBranch}:
      expectKind(item.last, nnkStmtList)
      item.last.add nnkBreakStmt.newTree(newEmptyNode())
    elif item.kind == nnkElse:
      item[0].add nnkBreakStmt.newTree(newEmptyNode())
  result = quote do:
    var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
    let accept: string = req.headers["accept"]
    let r = req.privAccpetParser.match(accept, mimes)
    var ext {.inject.}: string
    if r.ok:
      for item in mimes:
        ext = req.getExt(item.mime)
        headers["Content-Type"] = item.mime
        `body`
    else:
      `body`

proc gzip*(req: Request): bool = req.headers.hasKey("Accept-Encoding") and
    string(req.headers["Accept-Encoding"]).contains("gzip")

proc resp*(req: Request, content: string,
              headers: HttpHeaders = newHttpHeaders(), code: HttpCode = Http200): Future[void] {.async.} =
  ## Responds to the request with the specified ``HttpCode``, headers and
  ## content.
  # If the headers did not contain a Content-Length use our own
  let gzip = req.gzip()
  let originalLen = content.len
  let needCompress = gzip and originalLen >= gzipMinLength
  if needCompress:
    headers["Content-Encoding"] = "gzip"
  let ctn = if needCompress: compress(content, BestSpeed, dfGzip) else: content
  let flen = if needCompress: $(ctn.len) else: $originalLen
  headers.hasKeyOrPut("Content-Length"):
    flen
  headers.hasKeyOrPut("Date"):
    httpDate()
  var msg = generateHeaders(headers, code)
  msg.add(ctn)
  discard await req.transp.write(msg)

proc respError*(req: Request, code: HttpCode, content: string): Future[void] {.async.} =
  ## Responds to the request with the specified ``HttpCode``.
  var headers = genericHeaders()
  let gzip = req.gzip()
  let originalLen = content.len
  let needCompress = gzip and originalLen >= gzipMinLength
  if needCompress:
    headers["Content-Encoding"] = "gzip"
  let ctn = if needCompress: compress(content, BestSpeed, dfGzip) else: content
  let flen = if needCompress: $(ctn.len) else: $originalLen
  headers.hasKeyOrPut("Content-Length"):
    flen
  var msg = generateHeaders(headers, code)
  msg.add(ctn)
  discard await req.transp.write(msg)

proc respError*(req: Request, code: HttpCode): Future[void] {.async.} =
  ## Responds to the request with the specified ``HttpCode``.
  var headers = genericHeaders()
  let content = $code
  headers["Content-Length"] = $content.len
  var msg = generateHeaders(headers, code)
  msg.add(content)
  discard await req.transp.write(msg)

proc pairParam(x: tuple[key: string, value: string]): string =
  result = x[0] & '=' & '"' & x[1] & '"'

proc respBasicAuth*(req: Request, scheme = "Basic", realm = "Scorper", params: seq[tuple[key: string,
    value: string]] = @[], code = Http401): Future[void] {.async.} =
  ## Responds to the request with the specified ``HttpCode``.
  var headers = genericHeaders()
  let extro = if params.len > 0: "," & params.map(pairParam).join(",") else: ""
  headers["WWW-Authenticate"] = &"{scheme} realm={realm}" & extro
  let msg = generateHeaders(headers, code)
  discard await req.transp.write(msg)

proc respStatus*(request: Request, code: HttpCode, ver = HttpVer11): Future[void] {.async.} =
  discard await request.transp.write($ver & " " & $code & "Date: " & httpDate() & CRLF & CRLF)

proc respStatus*(request: Request, code: HttpCode, msg: string, ver = HttpVer11): Future[void] {.async.} =
  discard await request.transp.write($ver & " " & $code.int & msg & "Date: " & httpDate() & CRLF & CRLF)

proc writeFile(request: Request, fname: string, size: int): Future[void] {.async.} =
  var handle = 0
  var fhandle: File
  try:
    fhandle = open(fname)
  except IOError as e:
    echo e.msg
    return
  except CatchableError as e:
    echo e.msg
    return
  except Exception as e:
    echo e.msg
    return
  when defined(windows):
    handle = int(get_osfhandle(getFileHandle(fhandle)))
  else:
    handle = int(getFileHandle(fhandle))
  request.server.logSub.next(request.formatCommon(Http200, size))
  discard await request.transp.writeFile(handle, 0.uint, size)
  close(fhandle)

proc writePartialFile(request: Request, fname: string, ranges: seq[tuple[starts: int, ends: int]], meta: Option[tuple[
    info: FileInfo, headers: HttpHeaders]], boundary: string, mime: string) {.async.} =
  var handle = 0
  var fhandle: File
  try:
    fhandle = open(fname)
  except IOError as e:
    echo e.msg
    return
  let fullSize = meta.unsafeGet.info.size.int
  when defined(windows):
    handle = int(getOsFileHandle(getFileHandle(fhandle)))
  else:
    handle = int(getFileHandle(fhandle))

  for b in ranges:
    discard await request.transp.write(boundary & CRLF)
    discard await request.transp.write(fmt"Content-Type: {mime}" & CRLF)
    if b.ends > 0:
      discard await request.transp.write(fmt"Content-Range: bytes {b.starts}-{b.ends}/{fullSize}" & CRLF & CRLF)
    elif b.ends == 0:
      discard await request.transp.write(fmt"Content-Range: bytes {b.starts}-{fullSize - 1}/{fullSize}" & CRLF & CRLF)
    else:
      discard await request.transp.write(fmt"Content-Range: bytes {b.ends}/{fullSize}" & CRLF & CRLF)
    let offset = if b.ends >= 0: b.starts else: fullSize + b.ends
    let size = if b.ends > 0: b.ends - b.starts + 1: elif b.ends == 0: fullSize - b.starts else: abs(b.ends)
    let written = await request.transp.writeFile(handle, offset.uint, size)
  discard await request.transp.write(CRLF & boundary & "--")
  close(fhandle)

proc fileGuard(request: Request, filepath: string): Future[Option[FileInfo]] {.async.} =
  # If-Modified-Since: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.25
  # The result of a request having both an If-Modified-Since header field and either an If-Match or an If-Unmodified-Since header fields is undefined by this specification.
  if not fileExists(filepath):
    return none(FileInfo)
  var info: FileInfo
  try:
    info = getFileInfo(filepath)
  except:
    return none(FileInfo)
  if fpOthersRead notin info.permissions:
    await request.respError(Http403)
    return none(FileInfo)
  if request.headers.hasKey("If-Modified-Since"):
    var ifModifiedSince: Time
    try:
      ifModifiedSince = parseTime(request.headers["If-Modified-Since"], HttpDateFormat, utc())
    except:
      await request.respError(Http400)
      return none(FileInfo)
    if info.lastWriteTime == ifModifiedSince:
      await request.respStatus(Http304)
      return none(FileInfo)
  elif request.headers.hasKey("If-Unmodified-Since"):
    var ifUnModifiedSince: Time
    try:
      ifUnModifiedSince = parseTime(request.headers["If-Unmodified-Since"], HttpDateFormat, utc())
    except:
      await request.respError(Http400)
      return none(FileInfo)
    if info.lastWriteTime > ifUnModifiedSince:
      await request.respStatus(Http412)
      return none(FileInfo)
  return some(info)

proc fileMeta(request: Request, filepath: string): Future[Option[tuple[info: FileInfo, headers: HttpHeaders]]]{.async, inline.} =
  let info = await fileGuard(request, filepath)
  if not info.isSome():
    return none(tuple[info: FileInfo, headers: HttpHeaders])
  var size = info.get.size
  var headers = genericHeaders()
  headers["Content-Length"] = $size
  headers["Last-Modified"] = httpDate(info.get.lastWriteTime)
  return some((info: info.get, headers: headers))

proc calcContentLength(ranges: seq[tuple[starts: int, ends: int]], size: int): int =
  for b in ranges:
    if b[1] > 0:
      result = result + b[1] - b[0] + 1
    elif b[1] == 0:
      result = result + size - b[0]
    else:
      result = result + abs(b[1])

proc sendFile*(request: Request, filepath: string, extroHeaders: HttpHeaders = newHttpHeaders()) {.async.} =
  ## send file for display
  # Last-Modified: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29
  var meta = await fileMeta(request, filepath)
  if meta.isNone:
    await request.respError(Http404)
    return
  for key, val in extroHeaders:
    meta.unsafeGet.headers[key] = val
  var (_, _, ext) = splitFile(filepath)
  let mime = request.server.mimeDb.getMimetype(ext)
  let rangeRequest = request.headers.hasKey("Range")
  var parseRangeOk = false
  var ranges = newSeq[tuple[starts: int, ends: int]]()
  if rangeRequest:
    let parser = rangeParser()
    let rng: string = request.headers["Range"]
    let r = parser.match(rng, ranges)
    parseRangeOk = r.ok
  if not rangeRequest or not parseRangeOk:
    meta.unsafeGet.headers["Content-Type"] = mime
    var msg = generateHeaders(meta.unsafeGet.headers, Http200)
    discard await request.transp.write(msg)
    await request.writeFile(filepath, meta.unsafeGet.info.size.int)
    request.server.logSub.next(request.formatCommon(Http200, meta.unsafeGet.info.size.int))
  else:
    let boundary = "--" & $genOid()
    meta.unsafeGet.headers["Content-Type"] = "multipart/byteranges; " & boundary
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
      meta.unsafeGet.headers["Content-Length"] = $contentLength
      var msg = generateHeaders(meta.unsafeGet.headers, Http206)
      discard await request.transp.write(msg)
      await request.writePartialFile(filepath, ranges, meta, boundary, mime)
      request.server.logSub.next(request.formatCommon(Http206, contentLength))

proc sendDownload*(request: Request, filepath: string) {.async.} =
  ## send file directly without mime type , downloaded file name same as original
  # Last-Modified: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29
  var meta = await fileMeta(request, filepath)
  if meta.isNone:
    await request.respError(Http404)
    return
  meta.unsafeGet.headers["Content-Type"] = "application/x-download"
  var msg = generateHeaders(meta.unsafeGet.headers, Http200)
  discard await request.transp.write(msg)
  await request.writeFile(filepath, meta.unsafeGet.info.size.int)

proc sendAttachment*(request: Request, filepath: string, asName: string = "") {.async.} =
  let filename = if asName.len == 0: filepath.extractFilename else: asName
  let encodedFilename = &"filename*=UTF-8''{encodeUrlComponent(filename)}"
  let extroHeaders = newHttpHeaders({
    "Content-Disposition": &"""attachment;filename="{filename}";{encodedFilename}"""
  })
  await sendFile(request, filepath, extroHeaders)

proc serveStatic*(request: Request) {.async.} =
  if request.meth != HttpGet and request.meth != HttpHead:
    await request.respError(Http405)
    return
  let relPath = request.url.path.relativePath(request.prefix)
  let absPath = absolutePath(os.getEnv("StaticDir") / relPath)
  if not absPath.fileExists:
    await request.respError(Http404)
    return
  if request.meth == HttpHead:
    var meta = await fileMeta(request, absPath)
    if meta.isNone:
      await request.respError(Http404)
      return
    var (_, _, ext) = splitFile(absPath)
    let mime = request.server.mimeDb.getMimetype(ext)
    meta.unsafeGet.headers["Content-Type"] = mime
    meta.unsafeGet.headers["Accept-Ranges"] = "bytes"
    var msg = generateHeaders(meta.unsafeGet.headers, Http200)
    discard await request.transp.write(msg)
    return
  await request.sendFile(absPath)


proc json*(request: Request): Future[JsonNode] {.async.} =
  if request.parsedJson.isSome:
    return request.parsedJson.unSafeGet
  var str: string
  try:
    str = await request.transp.readLine(limit = request.contentLength.int)
  except AsyncStreamIncompleteError as e:
    await request.respStatus(Http400, ContentLengthMismatch)
    return
  result = parseJson(str)
  request.parsedJson = some(result)
  request.parsed = true

proc body*(request: Request): Future[string] {.async.} =
  if request.rawBody.isSome:
    return request.rawBody.unSafeGet
  try:
    result = await request.transp.readLine(limit = request.contentLength.int)
  except AsyncStreamIncompleteError as e:
    await request.respStatus(Http400, ContentLengthMismatch)
    return
  request.parsed = true

proc stream*(request: Request): AsyncStreamReader =
  doAssert request.transp.closed == false
  newAsyncStreamReader(request.transp)

proc form*(request: Request): Future[Form] {.async.} =
  if request.parsedForm.isSome:
    return request.parsedForm.unSafeGet
  result = newForm()
  case request.contentType:
    of "application/x-www-form-urlencoded":
      var parser = newUrlEncodedParser(request.transp, request.buf.addr, request.contentLength.int)
      var parsed = await parser.parse()
      for (key, value) in parsed:
        let v = if value.len > 0: decodeUrlComponent(value) else: ""
        let k = decodeUrlComponent key
        result.data.add ContentDisposition(kind: ContentDispositionKind.data, name: k, value: v)
    else:
      if request.contentType.len > 0:
        var parsed: tuple[i: int, boundary: string]
        try:
          parsed = parseBoundary(request.contentType)
        except BoundaryMissingError as e:
          await request.respError(Http400, e.msg)
          return
        except BoundaryInvalidError as e:
          await request.respError(Http400, e.msg)
          return
        var parser = newMultipartParser(parsed.boundary, request.transp, request.buf.addr, request.contentLength.int)
        await parser.parse()
        if parser.state == boundaryEnd:
          for disp in parser.dispositions:
            if disp.kind == ContentDispositionKind.data:
              result.data.add disp
            elif disp.kind == ContentDispositionKind.file:
              result.files.add disp
        else:
          echo "form parse error: " & $parser.state
      else:
        discard
  request.parsedForm = some(result)
  request.parsed = true

proc processRequest(
  scorper: Scorper,
  request: Request,
): Future[bool] {.async.} =
  request.parsed = false
  request.parsedJson = none(JsonNode)
  request.parsedForm = none(Form)
  request.headers.clear()
  # receivce untill http header end
  # note: headers field name is case-insensitive, field value is case sensitive
  const HeaderSep = @[byte('\c'), byte('\L'), byte('\c'), byte('\L')]
  var count: int
  try:
    count = await request.transp.readUntil(request.buf[0].addr, len(request.buf), sep = HeaderSep)
  except TransportIncompleteError:
    return true
  except TransportLimitError:
    await request.respStatus(Http400, BufferLimitExceeded)
    request.transp.close()
    return false
  # Headers
  let headerEnd = request.httpParser.parseHeader(addr request.buf[0], request.buf.len)
  if headerEnd == -1:
    await request.respError(Http400)
    return true
  request.httpParser.toHttpHeaders(request.headers)
  case request.httpParser.getMethod
    of "GET": request.meth = HttpGet
    of "POST": request.meth = HttpPost
    of "HEAD": request.meth = HttpHead
    of "PUT": request.meth = HttpPut
    of "DELETE": request.meth = HttpDelete
    of "PATCH": request.meth = HttpPatch
    of "OPTIONS": request.meth = HttpOptions
    of "CONNECT": request.meth = HttpConnect
    of "TRACE": request.meth = HttpTrace
    else:
      await request.respError(Http501)
      return true

  request.path = request.httpParser.getPath

  try:
    request.url = parseUrl("http://" & request.hostname & request.path)[]
  except ValueError as e:
    echo e.msg
    asyncSpawn request.respError(Http400)
    return true
  case request.httpParser.major[]:
    of '1':
      request.protocol.major = 1
    of '2':
      request.protocol.major = 2
    else:
      discard
  case request.httpParser.minor[]:
    of '0':
      request.protocol.minor = 0
    of '1':
      request.protocol.minor = 1
    else:
      discard
  if request.protocol == HttpVer20:
    await request.respStatus(Http505)
    return false

  if request.meth == HttpPost:
    # Check for Expect header
    if request.headers.hasKey("Expect"):
      if "100-continue" in request.headers["Expect"]:
        await request.respStatus(Http400)
      else:
        await request.respStatus(Http417)

  # Read the body
  # - Check for Content-length header
  if unlikely(request.meth in MethodNeedsBody):
    if request.headers.hasKey("Content-Length"):
      try:
        discard parseBiggestUInt(request.headers["Content-Length"], request.contentLength)
      except ValueError:
        await request.respStatus(Http400, "Invalid Content-Length.")
        return true
      if request.contentLength.int > scorper.maxBody:
        await request.respStatus(Http413)
        return false
      if request.headers.hasKey("Content-Type"):
        request.contentType = request.headers["Content-Type"]
    else:
      await request.respStatus(Http411)
      return true
  # Call the user's callback.
  if scorper.callback != nil:
    await scorper.callback(request)
  elif scorper.router != nil:
    let matched = scorper.router.match($request.meth, request.url.path)
    if matched.success:
      request.params = matched.route.params[]
      shallowCopy(request.query, request.url.query)
      request.prefix = matched.route.prefix
      await matched.handler(request)
    else:
      await request.respError(Http404)

  if "upgrade" in request.headers.getOrDefault("connection"):
    return false

  # The request has been served, from this point on returning `true` means the
  # connection will not be closed and will be kept in the connection pool.

  # Persistent connections
  if (request.protocol == HttpVer11 and
      cmpIgnoreCase(request.headers.getOrDefault("connection"), "close") != 0) or
     (request.protocol == HttpVer10 and
      cmpIgnoreCase(request.headers.getOrDefault("connection"), "keep-alive") == 0):
    # In HTTP 1.1 we assume that connection is persistent. Unless connection
    # header states otherwise.
    # In HTTP 1.0 we assume that the connection should not be persistent.
    # Unless the connection header states otherwise.
    return true
  else:
    request.transp.close()
    return false

proc processClient(server: StreamServer, transp: StreamTransport) {.async.} =
  var scorper = cast[Scorper](server)
  var req = Request()
  req.server = scorper
  req.headers = newHttpHeaders()
  req.transp = transp
  try:
    req.hostname = $req.transp.localAddress
  except TransportError:
    discard
  try:
    req.ip = $req.transp.remoteAddress
  except TransportError:
    discard
  req.privAccpetParser = accpetParser()
  req.httpParser = MofuParser()
  while not transp.atEof():
    let retry = await processRequest(scorper, req)
    if not retry:
      transp.close
      break

proc logSubOnNext(v: string) =
  echo v

proc serve*(address: string,
            callback: AsyncCallback,
            flags: set[ServerFlags] = {ReuseAddr},
            maxBody = 8.Mb
            ) {.async.} =
  var server = Scorper()
  server.mimeDb = newMimetypes()
  server.callback = callback
  server.maxBody = maxBody
  let address = initTAddress(address)
  server = cast[Scorper](createStreamServer(address, processClient, flags, child = cast[StreamServer](server)))
  server.logSub = subject[string]()
  server.start()
  when not defined(release):
    discard server.logSub.subscribe logSubOnNext
  server.logSub.next("Scorper serve at http://" & $address)
  await server.join()

proc setHandler*(self:Scorper,  handler: AsyncCallback) = 
  self.callback = handler

proc newScorper*(address: string,
                flags: set[ServerFlags] = {ReuseAddr},
                maxBody = 8.Mb
                ): Scorper =
  new result
  result.mimeDb = newMimetypes()
  result.maxBody = maxBody
  let address = initTAddress(address)
  result.logSub = subject[string]()
  when not defined(release):
    discard result.logSub.subscribe logSubOnNext
  result.logSub.next("Scorper serve at http://" & $address)
  result = cast[Scorper](createStreamServer(address, processClient, flags, child = cast[StreamServer](result)))


proc newScorper*(address: string, handler: AsyncCallback | Router[AsyncCallback],
                flags: set[ServerFlags] = {ReuseAddr},
                maxBody = 8.Mb
                ): Scorper =
  new result
  result.mimeDb = newMimetypes()
  when handler is AsyncCallback:
    result.callback = handler
  elif handler is Router[AsyncCallback]:
    result.router = handler
  result.maxBody = maxBody
  let address = initTAddress(address)
  result.logSub = subject[string]()
  when not defined(release):
    discard result.logSub.subscribe logSubOnNext
  result.logSub.next("Scorper serve at http://" & $address)
  result = cast[Scorper](createStreamServer(address, processClient, flags, child = cast[StreamServer](result)))

proc isClosed*(server: Scorper): bool =
  server.status = ServerStatus.Closed
