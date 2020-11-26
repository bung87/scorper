import chronos
import httpcore, urlly
import mofuparser, parseutils, strutils
import router
import netunit
import options
import json
import ./multipartparser
import ./httpform
import constant
import os
import mimetypes
import strformat

const MethodNeedsBody = {HttpPost, HttpPut, HttpConnect, HttpPatch}

let mimeDb = newMimetypes()

type
  Request* = ref object
    meth*: HttpMethod
    headers*: HttpHeaders
    protocol*: tuple[orig: string, major, minor: int]
    url*: Url
    path*: string # http request path
    hostname*: string
    params* : Table[string,string]
    query* : Table[string,string]
    transp: StreamTransport
    buf: array[HttpRequestBufferSize,char]
    httpParser: MofuParser
    contentLength: int
    contentType: string
    
  AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}
  Looper* = ref object of StreamServer
    callback: AsyncCallback
    maxBody: int
    router: Router[AsyncCallback]


proc `$`*(r: Request): string =
  var j = newJObject()
  j["url"] = % $r.url
  j["method"] = % $r.meth
  j["hostname"] = % r.hostname
  j["headers"] = %* r.headers.table
  result = $j

proc addHeaders(msg: var string, headers: HttpHeaders) =
  for k, v in headers:
    msg.add(k & ": " & v & "\c\L")

proc resp*(req: Request, content: string,
              headers: HttpHeaders = nil, code: HttpCode = 200.HttpCode): Future[void] {.async.}=
  ## Responds to the request with the specified ``HttpCode``, headers and
  ## content.
 
  var msg = "HTTP/1.1 " & $code & "\c\L"

  if headers != nil:
    msg.addHeaders(headers)

  # If the headers did not contain a Content-Length use our own
  if headers.isNil() or not headers.hasKey("Content-Length"):
    msg.add("Content-Length: ")
    # this particular way saves allocations:
    msg.addInt content.len
    msg.add "\c\L"

  msg.add "\c\L"
  msg.add(content)
  discard await req.transp.write(msg)

proc respError(req: Request, code: HttpCode): Future[void] {.async.}=
  ## Responds to the request with the specified ``HttpCode``.
  let content = $code
  var msg = "HTTP/1.1 " & content & "\c\L"

  msg.add("Content-Length: " & $content.len & "\c\L\c\L")
  msg.add(content)
  discard await req.transp.write(msg)

proc respBasicAuth*(req: Request, scheme = "Basic", realm = "Looper"): Future[void] {.async.}=
  ## Responds to the request with the specified ``HttpCode``.
  var msg = "HTTP/1.1 " & $Http401 & "\c\L"
  var headers = newHttpHeaders()
  headers["WWW-Authenticate"] = &"{scheme} realm={realm}"
  await req.resp( "",headers, Http401)

proc sendStatus(transp: StreamTransport, status: string): Future[void] {.async.}=
  discard await transp.write("HTTP/1.1 " & status & "\c\L\c\L")

proc writeFile(request: Request, fname:string, size:int) {.async.} = 
  var handle = 0
  var fhandle = open(fname)
  when defined(windows):
    handle = int(get_osfhandle(getFileHandle(fhandle)))
  else:
    handle = int(getFileHandle(fhandle))
  discard await request.transp.writeFile(handle, 0'u, size)
  close(fhandle)

proc sendFile*(request: Request, fname:string) {.async.} = 
  var (dir, name, ext) = splitFile(fname)
  let mime = mimeDb.getMimetype(ext) 
  var size = int(getFileSize(fname))
  var msg = "HTTP/1.1 " & $Http200 & "\c\L"
  
  msg.add("Content-Type: " & mime & "\c\L")
  msg.add("Content-Length: " & $size & "\c\L\c\L")
  discard await request.transp.write(msg)
  await request.writeFile(fname, size)

proc sendAttachment*(request: Request, fname:string) {.async.} = 
  var (dir, name, ext) = splitFile(fname)
  let mime = mimeDb.getMimetype(ext) 
  var size = int(getFileSize(fname))
  var msg = "HTTP/1.1 " & $Http200 & "\c\L"
  
  msg.add("Content-Type: " & mime & "\c\L")
  msg.add("Content-Length: " & $size & "\c\L")
  let filename = fname.extractFilename
  let encodedFilename = &"filename*=UTF-8''{encodeUrlComponent(filename)}"
  msg.add &"""Content-Disposition: attachment;filename="{filename}";{encodedFilename} """ & httpNewLine & httpNewLine
  discard await request.transp.write(msg)
  await request.writeFile(fname, size)

proc json*(request: Request): Future[JsonNode] {.async.} =
  var str: string
  try:
    str = await request.transp.readLine(limit = request.contentLength)
  except AsyncStreamIncompleteError:
    await request.resp("Bad Request. Content-Length does not match actual.", code = Http400)
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
        str = await request.transp.readLine(limit = request.contentLength)
      except AsyncStreamIncompleteError:
        await request.resp("Bad Request. Content-Length does not match actual.", code = Http400)
      let url = parseUrl "?" & str
      for (name,value) in url.query:
        result.data.add ContentDisposition(kind:ContentDispositionKind.data,name:name,value:value)
    else:
      if request.contentType.len > 0:
        let (index, boundary ) = parseBoundary(request.contentType)
        zeroMem(request.buf[0].addr,HttpRequestBufferSize)
        var parser = newMultipartParser(boundary, request.transp, request.buf.addr, request.contentLength)
        try:
          await parser.parse()
        except TransportIncompleteError as e:
          await request.transp.sendStatus("400 Bad Request")
          request.transp.close()
          raise e
        except TransportLimitError as e:
          await request.transp.sendStatus("400 Bad Request. " & "Buffer Limit Exceeded")
          request.transp.close()
          raise e
        except CatchableError as e:
          await request.transp.sendStatus("400 Bad Request")
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
  zeroMem(request.httpParser.headers.addr, request.httpParser.headers.len)
  request.hostname = $request.transp.localAddress
  # receivce untill http header end
  const HeaderSep = @[byte('\c'),byte('\L'),byte('\c'),byte('\L')]
  var count:int
  try:
    count = await request.transp.readUntil(request.buf[0].addr, len(request.buf), sep = HeaderSep)
  except TransportIncompleteError:
    return true
  except TransportLimitError:
    await request.transp.sendStatus("400 Bad Request. " & "Buffer Limit Exceeded")
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
  request.headers = request.httpParser.toHttpHeaders
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
    request.url = parseUrl("http://" & request.hostname & request.path)
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
  # Ensure the client isn't trying to DoS us.
  if request.headers.len > headerLimit:
    await request.transp.sendStatus("400 Bad Request")
    request.transp.close()
    return false

  if request.meth == HttpPost:
    # Check for Expect header
    if request.headers.hasKey("Expect"):
      if "100-continue" in request.headers["Expect"]:
        await request.transp.sendStatus("100 Continue")
      else:
        await request.transp.sendStatus("417 Expectation Failed")

  # Read the body
  # - Check for Content-length header
  if unlikely(request.meth in MethodNeedsBody):
    if request.headers.hasKey("Content-Length"):
      if parseSaturatedNatural(request.headers["Content-Length"], request.contentLength) == 0:
        await request.resp("Bad Request. Invalid Content-Length.", code = Http400 )
        return true
      else:
        if request.contentLength > looper.maxBody:
          await request.respError(code = Http413)
          return false
        if request.headers.hasKey("Content-Type"):
          let contentType:string = request.headers["Content-Type"]
          request.contentType = contentType.toLowerAscii
    else:
      await request.resp("Content-Length required.", code = Http411)
      return true
  # Call the user's callback.
  if looper.callback != nil:
    await looper.callback(request)
  elif looper.router != nil:
    let matched = looper.router.match($request.meth, request.url)
    if matched.success:
      request.params = matched.route.params[]
      request.query = matched.route.query[]
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
  req.headers = newHttpHeaders()
  req.transp = transp
  req.httpParser = MofuParser(headers: newSeqOfCap[MofuHeader](64))
  while not transp.atEof():
    let retry = await processRequest(
      looper, req
    )
    if not retry: 
      transp.close
      break

proc serve*(address: string,
            callback: AsyncCallback,
            flags: set[ServerFlags] = {ReuseAddr},
            maxBody = 8.Mb
            ) {.async.} =
  var server = Looper()
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
  when handler is AsyncCallback:
    result.callback = handler
  elif handler is Router[AsyncCallback]:
    result.router = handler
  result.maxBody = maxBody
  let address = initTAddress(address)
  result = cast[Looper](createStreamServer(address, processClient, flags, child = cast[StreamServer](result)))

proc isClosed*(server:Looper):bool =
  server.status = ServerStatus.Closed