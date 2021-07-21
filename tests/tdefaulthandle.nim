
import ./scorper/http/streamserver
import ./scorper/http/httprequest
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import json, strutils
import asynctest, strformat

var server: Scorper

suite "test default handler with mime":
  setup:
    proc handler(request: Request) {.closure, async.} =
      let j = await request.json()
      await request.resp($j)
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
      let headers = {"Content-Type": "application/json", "Accept": "application/json"}.newHttpHeaders()
      let clientResponse = await client.sendJson(fmt"http://127.0.0.1:{server.local.port}/",
          body = """{ "name": "Nim" "age": 12 }""", headers = headers)
      await client.close()

      return clientResponse
    let
      response = await request(server)
      body = await response.readBody()

    doAssert(response.code != Http200)
    doAssert response.contentType == "application/json"
    doAssert body.contains("Error")

  test "testTextError":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let
        client = newAsyncHttpClient()
      let headers = {"Content-Type": "application/json"}.newHttpHeaders()
      let clientResponse = await client.sendJson(fmt"http://127.0.0.1:{server.local.port}/",
          body = """{ "name": "Nim" "age": 12 }""", headers = headers)
      await client.close()

      return clientResponse
    let
      response = await request(server)
      body = await response.readBody()

    doAssert(response.code != Http200)
    doAssert response.contentType == "text/plain"
    doAssert("Error" in body)

