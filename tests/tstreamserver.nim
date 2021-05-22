discard """
  cmd: "nim c --threads:on -d:release -d:danger $file "
  exitcode: 0
  output: "OK"
  disabled: false
"""

import strutils
from net import TimeoutError
include ./scorper/http/streamserver
include ./scorper/http/streamclient

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Scorper): Future[AsyncResponse],
    test: proc (response: AsyncResponse, body: string): Future[void]) =

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

proc test200() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp("Hello World, 200")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(TestUrl)
    await client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")
  try:
    runTest(handler, request, test)
  except:
    discard

proc test404() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp("Hello World, 404", code = Http404)

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(TestUrl)
    await client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http404)
    doAssert(body == "Hello World, 404")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")
  try:
    runTest(handler, request, test)
  except:
    discard

proc testCustomEmptyHeaders() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp("Hello World, 200", newHttpHeaders())

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(TestUrl)
    await client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")
  try:
    runTest(handler, request, test)
  except:
    discard

proc testCustomContentLength() {.async.} =
  proc handler(request: Request) {.async.} =
    let headers = newHttpHeaders()
    headers["Content-Length"] = "0"
    await request.resp("Hello World, 200", headers)

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(TestUrl)
    await client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "0")
  try:
    runTest(handler, request, test)
  except:
    discard

proc testPost() {.async.} =
  proc handler(request: Request) {.async.} =
    let body = await request.body()
    doAssert(body == "hello")
    await request.resp("Hello World, 200")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.post(TestUrl, body = "hello")
    await client.close()
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
  try:
    runTest(handler, request, test)
  except:
    discard

waitfor(test200())
waitfor(test404())
waitfor(testCustomEmptyHeaders())
waitfor(testCustomContentLength())
waitfor(testPost())

echo "OK"
