
import ./looper/http/streamserver
import ./looper/http/streamclient
import httpcore,chronos
import json

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

proc testJson() {.async.} =
  proc handler(request: Request) {.async.} =
    let j = await request.json()
    await request.resp($j)

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
    
    let clientResponse = await client.sendJson(TestUrl,body = """{ "name": "Nim", "age": 12 }""")
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    var s:string
    toUgly(s,parseJson("""{ "name": "Nim", "age": 12 }""") )
    doAssert(body == s)

  runTest(handler, request, test)
waitfor(testJson())

echo "OK"