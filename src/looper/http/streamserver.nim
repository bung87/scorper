
##
## This module implements a stream http server
## depends on chronos
##
## Copyright (c) 2020 Bung

import chronos
import mofuparser, parseutils, strutils
import multipartparser, httpform, httpdate ,httpcore, urlly, router, netunit, constant
import std / [os,options,strformat,times,mimetypes,json ]

const MethodNeedsBody = {HttpPost, HttpPut, HttpConnect, HttpPatch}

type
  Request* = ref object
    meth*: HttpMethod
    headers*: HttpHeaders
    protocol*: tuple[major, minor: int]
    url*: Url
    path*: string # http request path
    hostname*: string
    ip*: string
    params* : Table[string,string]
    query* : seq[(string, string)]
    transp: StreamTransport
    buf: array[HttpRequestBufferSize,char]
    httpParser: MofuParser
    contentLength: BiggestUInt # as RFC no limit
    contentType: string
    server: Looper
    prefix: string
    
  AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}
  Looper* = ref object of StreamServer
    callback: AsyncCallback
    maxBody: int
    router: Router[AsyncCallback]
    mimeDb: MimeDB 

proc `$`*(r: Request): string =
  var j = newJObject()
  j["url"] = % $r.url
  j["method"] = % $r.meth
  j["hostname"] = % r.hostname
  j["headers"] = %* r.headers.table
  result = $j

proc genericHeaders():HttpHeaders = 
  # Date: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.18
  result = newHttpHeaders()
  result["Date"] = httpDate()

proc resp*(req: Request, content: string,
              headers: HttpHeaders = newHttpHeaders(), code: HttpCode = Http200): Future[void] {.async.}=
  ## Responds to the request with the specified ``HttpCode``, headers and
  ## content.
  # If the headers did not contain a Content-Length use our own
  headers.hasKeyOrPut("Content-Length"):
    $(content.len)
  headers.hasKeyOrPut("Date"):
    httpDate()
  var msg = generateHeaders(headers, code)
  msg.add(content)
  discard await req.transp.write(msg)

proc respError*(req: Request, code: HttpCode, detail:string ): Future[void] {.async.}=
  ## Responds to the request with the specified ``HttpCode``.
  var headers = genericHeaders()
  let detailLen = detail.len
  headers["Content-Length"] = $detailLen
  var msg = generateHeaders(headers, code)
  msg.add(detail)
  discard await req.transp.write(msg)

proc respError*(req: Request, code: HttpCode): Future[void] {.async.}=
  ## Responds to the request with the specified ``HttpCode``.
  var headers = genericHeaders()
  let content = $code
  headers["Content-Length"] = $content.len
  var msg = generateHeaders(headers, code)
  msg.add(content)
  discard await req.transp.write(msg)

proc respBasicAuth*(req: Request, scheme = "Basic", realm = "Looper"): Future[void] {.async.}=
  ## Responds to the request with the specified ``HttpCode``.
  var headers = genericHeaders()
  headers["WWW-Authenticate"] = &"{scheme} realm={realm}"
  let msg = generateHeaders(headers, Http401)
  discard await req.transp.write(msg)

proc respStatus*(request: Request, code: HttpCode, ver = HttpVer11): Future[void] {.async.}=
  discard await request.transp.write($ver & " " & $code & "Date: " & httpDate() & CRLF & CRLF)

proc respStatus*(request: Request, code: HttpCode, msg: string, ver = HttpVer11): Future[void] {.async.}=
  discard await request.transp.write($ver & " " & $code.int & msg & "Date: " & httpDate() & CRLF & CRLF)

proc writeFile(request: Request, fname:string, size:int) {.async.} = 
  var handle = 0
  var fhandle = open(fname)
  when defined(windows):
    handle = int(get_osfhandle(getFileHandle(fhandle)))
  else:
    handle = int(getFileHandle(fhandle))
  discard await request.transp.writeFile(handle, 0'u, size)
  close(fhandle)

proc fileGuard(request: Request, filepath:string): Future[Option[FileInfo]] {.async.} =
  # If-Modified-Since: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.25
  # The result of a request having both an If-Modified-Since header field and either an If-Match or an If-Unmodified-Since header fields is undefined by this specification.
  let info = getFileInfo(filepath)
  if fpOthersRead notin info.permissions:
    await request.respError(Http403)
    return none(FileInfo)
  if request.headers.hasKey("If-Modified-Since"):
    var ifModifiedSince: Time
    try:
      ifModifiedSince = parseTime(request.headers["If-Modified-Since"],HttpDateFormat, utc())
    except:
      await request.respError(Http400)
      return none(FileInfo)
    if info.lastWriteTime == ifModifiedSince:
      await request.respStatus(Http304)
      return none(FileInfo)
  elif request.headers.hasKey("If-Unmodified-Since"):
    var ifUnModifiedSince: Time
    try:
      ifUnModifiedSince = parseTime(request.headers["If-Unmodified-Since"],HttpDateFormat, utc())
    except:
      await request.respError(Http400)
      return none(FileInfo)
    if info.lastWriteTime > ifUnModifiedSince:
      await request.respStatus(Http412)
      return none(FileInfo)
  return some(info)

proc sendFile*(request: Request, filepath:string) {.async.} = 
  ## send file for display
  # Last-Modified: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29
  let info = await fileGuard(request, filepath)
  if not info.isSome():
    return 
  var (dir, name, ext) = splitFile(filepath)
  let mime = request.server.mimeDb.getMimetype(ext) 
  var size = int(info.get.size)
  var headers = genericHeaders()
  headers["Last-Modified"] = httpDate(info.get.lastWriteTime)
  headers["Content-Type"] = mime
  headers["Content-Length"] = $size
  var msg = generateHeaders(headers,Http200)
  discard await request.transp.write(msg)
  await request.writeFile(filepath, size)

proc sendDownload*(request: Request, filepath:string) {.async.} = 
  ## send file directly without mime type , downloaded file name same as original
  # Last-Modified: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29
  let info = await fileGuard(request, filepath)
  if not info.isSome():
    return 
  var (dir, name, ext) = splitFile(filepath)
  var size = int(info.get.size)
  var headers = genericHeaders()
  headers["Last-Modified"] = httpDate(info.get.lastWriteTime)
  headers["Content-Type"] = "application/x-download"
  headers["Content-Length"] = $size
  var msg = generateHeaders(headers,Http200)
  discard await request.transp.write(msg)
  await request.writeFile(filepath, size)

proc sendAttachment*(request: Request, filepath:string, asName: string = "") {.async.} = 
  let info = await fileGuard(request, filepath)
  if not info.isSome():
    return
  var (dir, name, ext) = splitFile(filepath)
  let mime = request.server.mimeDb.getMimetype(ext) 
  var size = int(info.get.size)
  var headers = genericHeaders()
  headers["Last-Modified"] = httpDate(info.get.lastWriteTime)
  headers["Content-Type"] = mime
  headers["Content-Length"] = $size
  var msg = generateHeaders(headers,Http200)
  let filename = if asName.len == 0: filepath.extractFilename else: asName
  let encodedFilename = &"filename*=UTF-8''{encodeUrlComponent(filename)}"
  msg.add &"""Content-Disposition: attachment;filename="{filename}";{encodedFilename} """ & CRLF & CRLF
  discard await request.transp.write(msg)
  await request.writeFile(filepath, size)

proc serveStatic*(request: Request) {.async.} =
  if request.meth != HttpGet:
    await request.respError(Http405)
    return
  let relPath = request.url.path.relativePath(request.prefix)
  let absPath =  absolutePath(os.getEnv("StaticDir") / relPath)
  if not absPath.fileExists:
    await request.respError(Http404)
    return
  await request.sendFile(absPath)

proc json*(request: Request): Future[JsonNode] {.async.} =
  var str: string
  try:
    str = await request.transp.readLine(limit = request.contentLength.int)
  except AsyncStreamIncompleteError as e:
    await request.respStatus(Http400, ContentLengthMismatch)
    raise e
  result = parseJson(str)

proc stream*(request: Request): AsyncStreamReader =
  doAssert request.transp.closed == false
  newAsyncStreamReader(request.transp)

proc form*(request: Request): Future[Form] {.async.} =
  result = newForm()
  case request.contentType:
    of "application/x-www-form-urlencoded":
      var str: string
      try:
        str = await request.transp.readLine(limit = request.contentLength.int)
      except AsyncStreamIncompleteError as e:
        await request.respStatus(Http400, ContentLengthMismatch)
        raise e
      let url = parseUrl "?" & str
      for (name,value) in url.query:
        result.data.add ContentDisposition(kind:ContentDispositionKind.data,name:name,value:value)
    else:
      if request.contentType.len > 0:
        var parsed:tuple[i:int,boundary:string]
        try:
          parsed = parseBoundary(request.contentType)
        except BoundaryMissingError as e:
          await request.respError(Http400, e.msg)
          raise e
        except BoundaryInvalidError as e:
          await request.respError(Http400, e.msg)
          raise e
        var parser = newMultipartParser(parsed.boundary, request.transp, request.buf.addr, request.contentLength.int)
        try:
          await parser.parse()
        except TransportIncompleteError as e:
          await request.respStatus(Http400)
          request.transp.close()
          raise e
        except TransportLimitError as e:
          await request.respStatus(Http400, BufferLimitExceeded)
          request.transp.close()
          raise e
        except CatchableError as e:
          await request.respStatus(Http400, BufferLimitExceeded)
          request.transp.close()
          raise e
        if parser.state == boundaryEnd:
          for disp in parser.dispositions:
            if disp.kind == ContentDispositionKind.data:
              result.data.add disp
            elif disp.kind == ContentDispositionKind.file:
              result.files.add disp
      else:
        return result

proc processRequest(
  looper: Looper,
  request: Request,
): Future[bool] {.async.} =

  request.headers.clear()
  
  # receivce untill http header end
  # note: headers field name is case-insensitive, field value is case sensitive
  const HeaderSep = @[byte('\c'),byte('\L'),byte('\c'),byte('\L')]
  var count:int
  try:
    count = await request.transp.readUntil(request.buf[0].addr, len(request.buf), sep = HeaderSep)
  except TransportIncompleteError:
    return true
  except TransportLimitError:
    await request.respStatus(Http400, BufferLimitExceeded)
    request.transp.close()
    return false
  except CatchableError as e:
    echo e.msg
    echo "CatchableError error"
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
  except ValueError:
    asyncCheck request.respError(Http400)
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
      if request.contentLength.int > looper.maxBody:
        await request.respStatus(Http413)
        return false
      if request.headers.hasKey("Content-Type"):
        request.contentType = request.headers["Content-Type"]
    else:
      await request.respStatus(Http411)
      return true
  # Call the user's callback.
  if looper.callback != nil:
    await looper.callback(request)
  elif looper.router != nil:
    let matched = looper.router.match($request.meth, request.url)
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
  var looper = cast[Looper](server)
  var req = Request()
  req.server = looper
  req.headers = newHttpHeaders()
  req.transp = transp
  req.hostname = $req.transp.localAddress
  req.ip = $req.transp.remoteAddress
  req.httpParser = MofuParser()
  while not transp.atEof():
    let retry = await processRequest(looper, req)
    if not retry: 
      transp.close
      break

proc serve*(address: string,
            callback: AsyncCallback,
            flags: set[ServerFlags] = {ReuseAddr},
            maxBody = 8.Mb
            ) {.async.} =
  var server = Looper()
  server.mimeDb = newMimetypes()
  server.callback = callback
  server.maxBody = maxBody
  let address = initTAddress(address)
  server = cast[Looper](createStreamServer(address, processClient, flags, child = cast[StreamServer](server)))
  server.start()
  await server.join()

proc newLooper*(address: string, handler:AsyncCallback | Router[AsyncCallback],
                flags: set[ServerFlags] = {ReuseAddr},
                maxBody = 8.Mb
                ): Looper =
  new result
  result.mimeDb = newMimetypes()
  when handler is AsyncCallback:
    result.callback = handler
  elif handler is Router[AsyncCallback]:
    result.router = handler
  result.maxBody = maxBody
  let address = initTAddress(address)
  result = cast[Looper](createStreamServer(address, processClient, flags, child = cast[StreamServer](result)))

proc isClosed*(server:Looper):bool =
  server.status = ServerStatus.Closed