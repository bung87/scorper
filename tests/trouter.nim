
import ./looper/http/streamserver
import ./looper/http/streamclient
import ./looper/http/router
import httpcore,chronos
import tables

const TestUrl = "http://127.0.0.1:64124/foo/ba?q=qux"
type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Looper): Future[AsyncResponse],
    test: proc (response: AsyncResponse, body: string): Future[void])  =

  let address = "127.0.0.1:64124"
  let flags = {ReuseAddr}
  let r = newRouter[AsyncCallback]()
  r.addRoute(handler, "get","/{p1}/{p2}")
  var server = newLooper(address, r, flags)
  server.start()
  let
    response = waitFor(request(server))
    body = waitFor(response.readBody())

  waitFor test(response, body)
  server.stop()
  server.close()
  waitFor server.join()

proc testJson() {.async.} =
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
waitfor(testJson())

echo "OK"