import chronos
import httpcore, urlly
import mofuparser, parseutils, strutils

type
  Request* = ref object
    reqMethod*: HttpMethod
    headers*: HttpHeaders
    protocol*: tuple[orig: string, major, minor: int]
    url*: Url
    hostname*: string
    transp: StreamTransport
    buf: array[1024,char]

  AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}
  Looper = ref object of StreamServer
    callback: AsyncCallback
    maxBody: int

proc addHeaders(msg: var string, headers: HttpHeaders) =
  for k, v in headers:
    msg.add(k & ": " & v & "\c\L")

proc respond*(req: Request, code: HttpCode, content: string,
              headers: HttpHeaders = nil): Future[void] {.async.}=
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

proc respondError(req: Request, code: HttpCode): Future[void] {.async.}=
  ## Responds to the request with the specified ``HttpCode``.
  let content = $code
  var msg = "HTTP/1.1 " & content & "\c\L"

  msg.add("Content-Length: " & $content.len & "\c\L\c\L")
  msg.add(content)
  discard await req.transp.write(msg)

proc sendStatus(transp: StreamTransport, status: string): Future[void] {.async.}=
  discard await transp.write("HTTP/1.1 " & status & "\c\L\c\L")

proc processRequest(
  looper: Looper,
  request: Request,
): Future[bool] {.async.} =

  request.headers.clear()
  request.hostname = $request.transp.localAddress
  # receivce untill http header end
  const HeaderSep = @[byte('\c'),byte('\L'),byte('\c'),byte('\L')]
  var count:int
  try:
    count = await request.transp.readUntil(request.buf[0].addr, len(request.buf), sep = HeaderSep)
  except TransportIncompleteError:
    return true
  # Headers
  var mfParser = MofuParser()
  let headerEnd = mfParser.parseHeader(addr request.buf[0], request.buf.len)
  case mfParser.getMethod
    of "GET": request.reqMethod = HttpGet
    of "POST": request.reqMethod = HttpPost
    of "HEAD": request.reqMethod = HttpHead
    of "PUT": request.reqMethod = HttpPut
    of "DELETE": request.reqMethod = HttpDelete
    of "PATCH": request.reqMethod = HttpPatch
    of "OPTIONS": request.reqMethod = HttpOptions
    of "CONNECT": request.reqMethod = HttpConnect
    of "TRACE": request.reqMethod = HttpTrace
  try:
    request.url = parseUrl(mfParser.getPath)
  except ValueError:
    asyncCheck request.respondError(Http400)
    return true
  case mfParser.minor[]:
    of '0': 
      request.protocol.major = 1
      request.protocol.minor = 0
    of '1':
      request.protocol.major = 1
      request.protocol.minor = 1
    else:
      discard
  request.headers = mfParser.toHttpHeaders
  # Ensure the client isn't trying to DoS us.
  if request.headers.len > headerLimit:
    await request.transp.sendStatus("400 Bad Request")
    request.transp.close()
    return false

  if request.reqMethod == HttpPost:
    # Check for Expect header
    if request.headers.hasKey("Expect"):
      if "100-continue" in request.headers["Expect"]:
        await request.transp.sendStatus("100 Continue")
      else:
        await request.transp.sendStatus("417 Expectation Failed")

  # Read the body
  # - Check for Content-length header
  if request.headers.hasKey("Content-Length"):
    var contentLength = 0
    if parseSaturatedNatural(request.headers["Content-Length"], contentLength) == 0:
      await request.respond(Http400, "Bad Request. Invalid Content-Length.")
      return true
    else:
      if contentLength > looper.maxBody:
        await request.respondError(Http413)
        return false
      await request.transp.readExactly(addr request.buf[count],contentLength)
      if request.buf.len != contentLength:
        await request.respond(Http400, "Bad Request. Content-Length does not match actual.")
        return true
  elif request.reqMethod == HttpPost:
    await request.respond(Http411, "Content-Length required.")
    return true

  # Call the user's callback.
  await looper.callback(request)

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
  while not transp.atEof():
    let retry = await processRequest(
      looper, req
    )
    if not retry: 
      transp.close
      break

proc serve*(address: TransportAddress,
            callback: AsyncCallback,
            flags: set[ServerFlags] = {ReuseAddr}
            ) {.async.} =
  var looper = Looper()
  looper.callback = callback
  let pserver = createStreamServer(address, processClient, flags, child = cast[StreamServer](looper))
  pserver.start()
  await pserver.join()

when isMainModule:
  proc cb(req: Request) {.async.} =
    echo req.hostname
    echo req.reqMethod
    echo req.headers
    echo req.protocol
    echo req.url
    let headers = {"Date": "Tue, 29 Apr 2014 23:40:08 GMT",
        "Content-type": "text/plain; charset=utf-8"}
    await req.respond(Http200, "Hello World", headers.newHttpHeaders())
  let address = initTAddress("127.0.0.1:8888")
  waitFor serve(address,cb)