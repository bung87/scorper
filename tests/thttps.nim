include ./cert

import strutils
from net import TimeoutError
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import chronos
import chronos / streams/tlsstream

const TestUrl = "https://127.0.0.1:64124/foo?bar=qux"

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (client: AsyncHttpClient): Future[AsyncResponse],
    test: proc (response: AsyncResponse, body: string): Future[void]): Future[void]{.async.} =

  let address = "127.0.0.1:64124"
  let flags: set[ServerFlags] = {ReuseAddr, ServerFlags.TcpNoDelay}
  var server = newScorper(address,
    handler,
    flags,
    isSecurity = true,
    privateKey = HttpsSelfSignedRsaKey,
    certificate = HttpsSelfSignedRsaCert,
    secureFlags = {NoVerifyHost, NoVerifyServerName}
    )
  server.start()
  let
    client = newAsyncHttpClient()
  let
    response = await request(client)
    body = await response.readBody()
  await client.close
  await test(response, body)
  server.stop()
  server.close()
  await server.join()

proc test200() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp("Hello World, 200")

  proc request(client: AsyncHttpClient): Future[AsyncResponse] {.async.} =
    let
      clientResponse = await client.request(TestUrl)
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  await runTest(handler, request, test)

proc test404() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp("Hello World, 404", code = Http404)

  proc request(client: AsyncHttpClient): Future[AsyncResponse] {.async.} =
    let clientResponse = await client.request(TestUrl)
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http404)
    doAssert(body == "Hello World, 404")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  await runTest(handler, request, test)

proc testCustomEmptyHeaders() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.resp("Hello World, 200", newHttpHeaders())

  proc request(client: AsyncHttpClient): Future[AsyncResponse] {.async.} =
    let
      clientResponse = await client.request(TestUrl)
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  await runTest(handler, request, test)

proc testCustomContentLength() {.async.} =
  proc handler(request: Request) {.async.} =
    let headers = newHttpHeaders()
    headers["Content-Length"] = "0"
    await request.resp("Hello World, 200", headers)

  proc request(client: AsyncHttpClient): Future[AsyncResponse] {.async.} =
    let
      clientResponse = await client.request(TestUrl)
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "0")

  await runTest(handler, request, test)

proc testPost() {.async.} =
  proc handler(request: Request) {.async.} =
    let body = await request.body()
    echo "repr body", repr body
    doAssert(body == "hello")
    await request.resp("Hello World, 200")

  proc request(client: AsyncHttpClient): Future[AsyncResponse] {.async.} =
    let
      clientResponse = await client.post(TestUrl, body = "hello")
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")

  await runTest(handler, request, test)

waitfor(test200())
echo 1
waitfor(test404())
echo 2
waitfor(testCustomEmptyHeaders())
echo 3
waitfor(testCustomContentLength())
echo 4
waitfor(testPost())

echo "OK"
