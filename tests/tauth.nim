
import ./looper/http/streamserver
import ./looper/http/streamclient
import ./looper/http/router
import httpcore,chronos
import tables
import strformat
import base64

type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Looper): Future[AsyncResponse],
    test: proc (response: AsyncResponse, body: string): Future[void])  =

  let address = "127.0.0.1:64124"
  let flags = {ReuseAddr}
  let r = newRouter[AsyncCallback]()
  r.addRoute(handler, "get","/auth/ok")
  r.addRoute(handler, "get","/auth/error")
  var server = newLooper(address, r, flags)
  server.start()
  let
    response = waitFor(request(server))
    body = waitFor(response.readBody())

  waitFor test(response, body)
  server.stop()
  server.close()
  waitFor server.join()

proc testAuthOk() {.async.} =
  proc handler(req: Request) {.async.} =
    if req.headers.hasKey("Authorization"):
      await req.resp("")
    else:
      await req.respBasicAuth()

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request("http://127.0.0.1:64124/auth/ok")
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http401)
    var headers = newHttpHeaders()
    let uname = "123"
    let upass = "456"
    let encoded = base64.encode &"{uname}:{upass}"
    headers["Authorization"] = &"Basic {encoded}"
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request("http://127.0.0.1:64124/auth/ok",headers=headers)
    echo clientResponse.code
    doassert clientResponse.code == Http200
    client.close()

  runTest(handler, request, test)

waitfor(testAuthOk())


echo "OK"