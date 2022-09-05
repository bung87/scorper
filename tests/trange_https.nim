
import ./scorper/http/streamserver
import ./scorper/http/httprequest
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import os, strutils
import asynctest, strformat
include ./cert


suite "test range request with ssl":
  var server{.threadvar.}: Scorper

  var handler = proc (request: Request) {.closure, async.} =
    await request.sendFile(currentSourcePath.parentDir() / "range.txt")

  setup:
    let address = "127.0.0.1:0"
    server = newScorper(address, handler, isSecurity = true,
    privateKey = HttpsSelfSignedRsaKey,
    certificate = HttpsSelfSignedRsaCert)
    server.start()

  teardown:
    server.stop()
    server.close()
    await server.join()

  test "testFull":
    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let client = newAsyncHttpClient()
      let clientResponse = await client.request(fmt"https://127.0.0.1:{server.local.port}/", headers = {
          "Range": "bytes=0-9"}.newHttpHeaders())
      await client.close()
      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert response.code == Http206
    # boundary start --60689fba61f1d82874ce9dc9
    doAssert response.contentLength == 125
    doAssert body.contains("0123456789")

  test "testStarts":
    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let client = newAsyncHttpClient()
      let clientResponse = await client.request(fmt"https://127.0.0.1:{server.local.port}/", headers = {
          "Range": "bytes=5-"}.newHttpHeaders())
      await client.close()
      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert response.code == Http206
    doAssert response.contentLength == 120
    doAssert body.contains("56789")


  test "testEnds":
    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let client = newAsyncHttpClient()
      let clientResponse = await client.request(fmt"https://127.0.0.1:{server.local.port}/", headers = {
          "Range": "bytes=-4"}.newHttpHeaders())
      await client.close()
      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert response.code == Http206
    doAssert response.contentLength == 118
    doAssert body.contains("6789")
