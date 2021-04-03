
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpcore,chronos
import os

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"
const source = staticRead(currentSourcePath.parentDir / "range.txt")
proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Scorper): Future[AsyncResponse],
    test: proc (response: AsyncResponse, body: string): Future[void])  =

  let address = "127.0.0.1:64124"
  let flags = {ReuseAddr}
  var server = newScorper(address, handler, flags)
  server.start()
  let
    response = waitFor(request(server))
    body = waitFor(response.readBody())

  waitFor test(response, body)
  server.stop()
  server.close()
  waitFor server.join()

proc testSendFIle() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.sendFile(currentSourcePath.parentDir / "range.txt")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
    
    let clientResponse = await client.request(TestUrl)
    await client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    let body = await response.readBody
    doAssert body == source

  runTest(handler, request, test)
waitfor(testSendFIle())

echo "OK"