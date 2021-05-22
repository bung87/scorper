
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import os
include ./cert

const TestUrl = "https://127.0.0.1:64124/foo?bar=qux"
const source = staticRead(currentSourcePath.parentDir / "range.txt")
proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (client: AsyncHttpClient): Future[AsyncResponse] {.raises: [].},
    test: proc (response: AsyncResponse, body: string): Future[void]){.async.} =

  let address = "127.0.0.1:64124"
  let flags: set[ServerFlags] = {ReuseAddr}
  var server: Scorper
  try:
    server = newScorper(address, handler, flags, isSecurity = true,
      privateKey = HttpsSelfSignedRsaKey,
      certificate = HttpsSelfSignedRsaCert)
  except:
    discard
  server.start()
  let
    client = newAsyncHttpClient()
  let
    response = await request(client)
    body = await response.readBody()
  await client.close
  try:
    await test(response, body)
  except:
    discard

  server.stop()
  server.close()
  waitFor server.join()

proc testSendFIle() {.async.} =
  proc handler(request: Request) {.async.} =
    await request.sendFile(currentSourcePath.parentDir / "range.txt")

  proc request(client: AsyncHttpClient): Future[AsyncResponse] {.async.} =
    let clientResponse = await client.request(TestUrl)
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    let body = await response.readBody
    doAssert body == source

  await runTest(handler, request, test)

waitfor(testSendFIle())

echo "OK"
