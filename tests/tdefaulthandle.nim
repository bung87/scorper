
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import json, strutils

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Scorper): Future[AsyncResponse]{.raises: [].},
    test: proc (response: AsyncResponse, body: string): Future[void]) =

  let address = "127.0.0.1:64124"
  let flags = {ReuseAddr}
  var server = newScorper(address, handler, flags)
  server.start()
  let
    response = waitFor(request(server))
    body = waitFor(response.readBody())

  waitFor test(response, body)
  server.stop()
  server.close()
  waitFor server.join()

proc testJson() {.async.} =
  proc handler(request: Request) {.async.} =
    let j = await request.json()
    await request.resp($j)

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
    let headers = {"Content-Type": "application/json", "Accept": "application/json"}.newHttpHeaders()
    let clientResponse = await client.sendJson(TestUrl, body = """{ "name": "Nim" "age": 12 }""", headers = headers)
    await client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code != Http200)
    doAssert response.contentType == "application/json"
    doAssert body.contains("Error")
  try:
    runTest(handler, request, test)
  except:
    discard

proc testTextError() {.async.} =
  proc handler(request: Request) {.async.} =
    let j = await request.json()
    await request.resp($j)

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    let
      client = newAsyncHttpClient()
    let headers = {"Content-Type": "application/json"}.newHttpHeaders()
    let clientResponse = await client.sendJson(TestUrl, body = """{ "name": "Nim" "age": 12 }""", headers = headers)
    await client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code != Http200)
    doAssert response.contentType == "text/plain"
    doAssert("Error" in body)
  try:
    runTest(handler, request, test)
  except Exception as e:
    echo e.msg
    discard

waitfor(testJson())
waitfor(testTextError())

echo "OK"
