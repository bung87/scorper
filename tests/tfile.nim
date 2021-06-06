
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import os
import asynctest, strformat

const source = staticRead(currentSourcePath.parentDir / "range.txt")

var server: Scorper

suite "test send file":
  setup:
    let address = "127.0.0.1:0"
    let flags = {ReuseAddr}
    server = newScorper(address, flags)
    server.start()
  teardown:
    server.stop()
    server.close()
    await server.join()
  test "testSendFIle":
    proc handler(request: Request) {.async.} =
      await request.sendFile(currentSourcePath.parentDir / "range.txt")
    server.setHandler handler
    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let
        client = newAsyncHttpClient()
      let testUrl = fmt"http://127.0.0.1:{server.local.port}"
      let clientResponse = await client.request(testUrl)
      await client.close()

      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert body == source

