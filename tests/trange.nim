
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import os, strutils

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"
proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Scorper): Future[AsyncResponse],
    test: proc (response: AsyncResponse, body: string): Future[void]) =

  let address = "127.0.0.1:64124"
  let flags:set[ServerFlags] = {ReuseAddr}
  var server = newScorper(address, handler, flags)
  server.start()
  let
    response = waitFor(request(server))
    body = waitFor(response.readBody())

  waitFor test(response, body)
  server.stop()
  server.close()
  waitFor server.join()

proc testFull() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.sendFile(currentSourcePath.parentDir() / "range.txt")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
    let clientResponse = await client.request(TestUrl, headers = {"Range": "bytes=0-9"}.newHttpHeaders())
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http206)
    doAssert body.contains("0123456789")

  runTest(handler, request, test)

proc testStarts() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.sendFile(currentSourcePath.parentDir() / "range.txt")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()

    let clientResponse = await client.request(TestUrl, headers = {"Range": "bytes=5-"}.newHttpHeaders())
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http206)
    doAssert body.contains("56789")

  runTest(handler, request, test)

proc testEnds() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.sendFile(currentSourcePath.parentDir() / "range.txt")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()

    let clientResponse = await client.request(TestUrl, headers = {"Range": "bytes=-4"}.newHttpHeaders())
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http206)
    doAssert body.contains("6789")

  runTest(handler, request, test)

waitfor(testFull())
waitfor(testStarts())
waitfor(testEnds())
echo "OK"
