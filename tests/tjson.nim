
import ./scorper/http/streamserver
import ./scorper/http/httprequest
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import json, strutils
import asynctest, strformat



suite "test json":
  var server: Scorper
  var handler = proc (request: Request) {.closure, async.} =
    let j = await request.json()
    await request.resp($j)
  setup:
    let address = "127.0.0.1:0"
    server = newScorper(address, handler)
    server.start()
  teardown:
    server.stop()
    server.close()
    await server.join()

  test "testJson":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let
        client = newAsyncHttpClient()

      let clientResponse = await client.sendJson(fmt"http://127.0.0.1:{server.local.port}/",
          body = """{ "name": "Nim", "age": 12 }""")
      await client.close()

      return clientResponse
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    var s: string
    try:
      toUgly(s, parseJson("""{ "name": "Nim", "age": 12 }"""))
    except:
      discard
    doAssert(body == s)

  test "testJsonError":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let
        client = newAsyncHttpClient()
      let body = """{ "name": "Nim" "age": 12 }"""
      let clientResponse = await client.sendJson(fmt"http://127.0.0.1:{server.local.port}/", body = body)
      await client.close()

      return clientResponse
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http400)
    doAssert("Error" in body)
