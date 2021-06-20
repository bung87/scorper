
import strutils
include ./scorper/http/streamserver
include ./scorper/http/streamclient
import asynctest, strformat
include ./cert

var server: Scorper

proc request(server: Scorper): Future[AsyncResponse] {.async.} =
  let testUrl = fmt"https://127.0.0.1:{server.local.port}"
  let
    client = newAsyncHttpClient()
    clientResponse = await client.request(testUrl)
  await client.close()

  return clientResponse

suite "test https":
  setup:
    let address = "127.0.0.1:0"
    server = newScorper(address, default(ScorperCallback), isSecurity = true,
    privateKey = HttpsSelfSignedRsaKey,
    certificate = HttpsSelfSignedRsaCert)
    server.start()

  teardown:
    server.stop()
    server.close()
    await server.join()

  test "http 200":
    proc handler(request: Request) {.async.} =
      await request.resp("Hello World, 200")
    server.setHandler handler
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  test "http 404":
    proc handler(request: Request) {.async.} =
      await request.resp("Hello World, 404", code = Http404)
    server.setHandler handler
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http404)
    doAssert(body == "Hello World, 404")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  test "CustomEmptyHeaders":
    proc handler(request: Request) {.async.} =
      await request.resp("Hello World, 200", newHttpHeaders())
    server.setHandler handler
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  test "CustomContentLength":
    proc handler(request: Request) {.async.} =
      let headers = newHttpHeaders()
      headers["Content-Length"] = "0"
      await request.resp("Hello World, 200", headers)
    server.setHandler handler
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "0")

  test "http post":
    proc handler(request: Request) {.async.} =
      let body = await request.body()
      doAssert(body == "hello")
      await request.resp("Hello World, 200")
    server.setHandler handler
    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let
        client = newAsyncHttpClient()
        clientResponse = await client.post(fmt"https://127.0.0.1:{server.local.port}", body = "hello")
      await client.close()
      return clientResponse
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")

