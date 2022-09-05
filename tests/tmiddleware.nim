import scorper/scorpermacros
import chronos
import asynctest
import strformat
import os
const TMPDIR = getTempDir()
const TMPFILE = TMPDIR / "scorper_middleware_log2.log"

proc abc(req: Request): Future[bool] {.async, postMiddleware.} =
  var f = open(TMPFILE, fmWrite)
  f.write("hello")
  f.flushFile
  f.close
  return false

# should under above imports
import scorper
import scorper/http/streamclient

suite "test middleware macros":
  var server{.threadvar.}: Scorper
  var client: AsyncHttpClient
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
    removeFile(TMPFILE)

  test "basic":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let clientResponse = await client.get(fmt"http://127.0.0.1:{server.local.port}/")
      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "Hello, World!")
    let c = readFile(TMPFILE)
    doAssert c == "hello"
