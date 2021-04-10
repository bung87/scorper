
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import os, strutils

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"

var server{.threadvar.}: Scorper

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Scorper): Future[AsyncResponse],
    test: proc (response: AsyncResponse, body: string): Future[void]) {.async.} =
  server.setHandler handler
  let
    response = await(request(server))
    body = await(response.readBody())
  await test(response, body)


proc testFull(client: AsyncHttpClient) {.async.} =
  proc handler(request: Request) {.async.} =
    await request.sendFile(currentSourcePath.parentDir() / "range.txt")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let clientResponse = await client.request(TestUrl, headers = {"Range": "bytes=0-9"}.newHttpHeaders())
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http206)
    # boundary start --60689fba61f1d82874ce9dc9
    doAssert response.contentLength == 125
    doAssert body.contains("0123456789")

  await runTest(handler, request, test)

proc testStarts(client: AsyncHttpClient) {.async.} =
  proc handler(request: Request) {.async.} =
    await request.sendFile(currentSourcePath.parentDir() / "range.txt")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let clientResponse = await client.request(TestUrl, headers = {"Range": "bytes=5-"}.newHttpHeaders())
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http206)
    doAssert response.contentLength == 120
    doAssert body.contains("56789")

  await runTest(handler, request, test)

proc testEnds(client: AsyncHttpClient) {.async.} =
  proc handler(request: Request) {.async.} =
    await request.sendFile(currentSourcePath.parentDir() / "range.txt")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let clientResponse = await client.request(TestUrl, headers = {"Range": "bytes=-4"}.newHttpHeaders())
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http206)
    doAssert response.contentLength == 118
    doAssert body.contains("6789")

  await runTest(handler, request, test)

let address = "127.0.0.1:64124"
let flags: set[ServerFlags] = {ReuseAddr, ReusePort}

server = newScorper(address, flags)
server.start()
let
  client = newAsyncHttpClient()
let
  client2 = newAsyncHttpClient()
let
  client3 = newAsyncHttpClient()
waitfor(testFull(client))

waitfor(testStarts(client2))

waitfor(testEnds(client3))
poll()
waitFor client.close()
waitFor client2.close()
waitFor client3.close()

server.stop()
waitFor server.closeWait()

echo "OK"
