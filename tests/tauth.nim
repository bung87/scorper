
import ./scorper/http/streamserver
import ./scorper/http/httprequest
import ./scorper/http/streamclient
import ./scorper/http/router
import ./scorper/http/httpcore, chronos
import tables
import strformat
import base64
import asynctest, strformat

var server: Scorper

suite "test auth":
  setup:
    proc handler(req: Request) {.closure, async.} =
      if req.headers.hasKey("Authorization"):
        await req.resp("")
      else:
        await req.respBasicAuth()
    let address = "127.0.0.1:0"
    let r = newRouter[ScorperCallback]()
    r.addRoute(handler, "get", "/auth/ok")
    r.addRoute(handler, "get", "/auth/error")
    server = newScorper(address, r)
    server.start()
  teardown:
    server.stop()
    server.close()
    await server.join()

  test "AuthOk":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let
        client = newAsyncHttpClient()
        clientResponse = await client.request(fmt"http://127.0.0.1:{server.local.port}/auth/ok")
      await client.close()

      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http401)
    var headers = newHttpHeaders()
    let uname = "123"
    let upass = "456"
    let encoded = base64.encode &"{uname}:{upass}"
    headers["Authorization"] = &"Basic {encoded}"
    let
      client = newAsyncHttpClient()
      clientResponse = await client.request(fmt"http://127.0.0.1:{server.local.port}/auth/ok", headers = headers)
    doassert clientResponse.code == Http200
    await client.close()

