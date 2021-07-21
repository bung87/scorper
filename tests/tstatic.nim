
import ./scorper/http/streamserver
import ./scorper/http/httprequest
import ./scorper/http/router
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import os
import asynctest, strformat

const root = currentSourcePath.parentDir().parentDir()
const source = staticRead(root / "README.md")

var server: Scorper

proc request(server: Scorper): Future[AsyncResponse] {.async.} =
  let
    client = newAsyncHttpClient()

  let clientResponse = await client.request(fmt"http://127.0.0.1:{server.local.port}/static/README.md")
  await client.close()

  return clientResponse

suite "test serve static file":
  setup:
    let address = "127.0.0.1:0"
    let flags = {ReuseAddr}
    let r = newRouter[proc (request: Request): Future[void] {.gcsafe.}]()
    r.addRoute(serveStatic, "get", "/static/*$")
    server = newScorper(address, r, flags)
    server.start()

  teardown:
    server.stop()
    server.close()
    await server.join()

  test "static file":
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert body == source

