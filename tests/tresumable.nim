
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import os

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"
const source = staticRead(currentSourcePath.parentDir / "range.txt")
proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Scorper): Future[void]) =

  let address = "127.0.0.1:64124"
  let flags = {ReuseAddr}
  var server = newScorper(address, handler, flags)
  server.start()
  waitFor(request(server))
  server.stop()
  server.close()
  waitFor server.join()

proc testSendFIle() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.respStatus(Http200)

  proc request(server: Scorper): Future[void] {.async.} =
    let
      client = newAsyncHttpClient()
    let filename = currentSourcePath.parentDir / "range.txt"
    await client.uploadResumable(filename, TestUrl)
    await client.close()

  runTest(handler, request)

waitfor(testSendFIle())

echo "OK"
