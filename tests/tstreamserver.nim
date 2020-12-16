discard """
  cmd: "nim c --threads:on -d:release -d:danger $file "
  exitcode: 0
  output: "OK"
  disabled: false
"""

import strutils
from net import TimeoutError
include ./looper/http/streamserver
include ./looper/http/streamclient

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

proc test200() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp("Hello World, 200")

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(TestUrl)
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  runTest(handler, request, test)

proc test404() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp( "Hello World, 404",code = Http404)

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(TestUrl)
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http404)
    doAssert(body == "Hello World, 404")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")
  
  runTest(handler, request, test)

proc testCustomEmptyHeaders() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp( "Hello World, 200", newHttpHeaders())

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(TestUrl)
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  runTest(handler, request, test)

proc testCustomContentLength() {.async.} =
  proc handler(request: Request) {.async.} =
    let headers = newHttpHeaders()
    headers["Content-Length"] = "0"
    await request.resp( "Hello World, 200", headers)

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(TestUrl)
    client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "0")

  runTest(handler, request, test)

proc testPost() {.async.} =
  proc handler(request: Request) {.async.} =
    let body = await request.body()
    doAssert(body == "hello")
    await request.resp("Hello World, 200")

  proc request(server: Looper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
      clientResponse = await client.post(TestUrl, body = "hello")
    client.close()
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")

  runTest(handler, request, test)

waitfor(test200())
waitfor(test404())
waitfor(testCustomEmptyHeaders())
waitfor(testCustomContentLength())
waitfor(testPost())

echo "OK"
