import scorper/scorpermacros
import chronos
import asynctest
import scorper/http/streamclient
import strformat
import os

proc abc(req: Request) {.async, postMiddleware.} =
  let p = getTempDir() / "scorper_middleware_log.log"
  var f = open(p, fmWrite)
  f.write("hello")
  f.flushFile
  f.close

import scorper

var server{.threadvar.}: Scorper
var client: AsyncHttpClient


suite "test middleware macros":
  setup:
    var handler = proc (req: Request) {.async.} =
      let headers = {"Content-type": "text/plain"}
      await req.resp("Hello, World!", headers.newHttpHeaders())

    if server == default(Scorper):
      let address = "127.0.0.1:0"
      server = newScorper(address)
      server.setHandler(handler)
      server.start()
      client = newAsyncHttpClient()

  teardown:
    server.stop()
    server.close()
    await server.join()

  test "basic":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let clientResponse = await client.get(fmt"http://127.0.0.1:{server.local.port}/")
      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "Hello, World!")
    let p = getTempDir() / "scorper_middleware_log.log"
    let c = readFile(p)
    doAssert c == "hello"
