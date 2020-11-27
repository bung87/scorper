
import ./looper/http/streamserver
import ./looper/http/streamclient
import ./looper/http/router
import ./looper/http/httpcore,chronos
import tables

const TestUrl = "http://127.0.0.1:64124/basic/foo/ba?q=qux"
type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Looper): Future[AsyncResponse],
    test: proc (response: AsyncResponse, body: string): Future[void])  =

  let address = "127.0.0.1:64124"
  let flags = {ReuseAddr}
  let r = newRouter[AsyncCallback]()
  r.addRoute(handler, "get","/basic/{p1}/{p2}")
  r.addRoute(handler, "get","/code/{codex}")
  var server = newLooper(address, r, flags)
  server.start()
  let
    response = waitFor(request(server))
    body = waitFor(response.readBody())

  waitFor test(response, body)
  server.stop()
  server.close()
  waitFor server.join()

proc testParams() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp($request.params & $request.query)

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(TestUrl)
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    let p = {"p1": "foo","p2": "ba"}.toTable
    let q = {"q": "qux"}.toTable
    doAssert(body == $p & $q)

  runTest(handler, request, test)

proc testParamEncode() {.async.} =
  proc handler(request: Request) {.async.} =
    doAssert request.params["codex"] == "ß"
    await request.resp("")

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      codeUrl = "http://127.0.0.1:64124/code/%C3%9F"
      clientResponse = await client.request(codeUrl)
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)

  runTest(handler, request, test)

proc testParamRaw() {.async.} =
  proc handler(request: Request) {.async.} =
    doAssert request.params["code"] == "ß"
    await request.resp("")

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      codeUrl = "http://127.0.0.1:64124/code/ß"
      clientResponse = await client.request(codeUrl)
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http400)

  runTest(handler, request, test)

waitfor(testParams())
waitfor(testParamEncode())
waitfor(testParamRaw())


echo "OK"