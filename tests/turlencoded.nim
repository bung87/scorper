
import ./looper/http/streamserver
import ./looper/http/streamclient
import ./looper/http/httpform
import ./looper/http/httpcore,chronos

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Looper): Future[AsyncResponse],
    test: proc (response: AsyncResponse, body: string): Future[void])  =

  let address = "127.0.0.1:64124"
  let flags = {ReuseAddr}
  var server = newLooper(address, handler, flags)
  server.start()
  let
    response = waitFor(request(server))
    body = waitFor(response.readBody())

  waitFor test(response, body)
  server.stop()
  server.close()
  waitFor server.join()

proc testUrlEncoded() {.async.} =
  proc handler(request: Request) {.async.} =
    let form = await request.form
    doAssert form.data["nim"] == "https://nim-lang.org"
    await request.resp("")

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
    var headers = newHttpHeaders([(key:"Content-Type",val:"application/x-www-form-urlencoded")])
    let clientResponse = await client.request(TestUrl,httpMethod = HttpPost,headers=headers,body = """nim=https%3A%2F%2Fnim-lang.org""")
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)

  runTest(handler, request, test)
waitfor(testUrlEncoded())

echo "OK"