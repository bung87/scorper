
import ./scorper/http/streamserver
import ./scorper/http/httprequest
import ./scorper/http/streamclient
import ./scorper/http/httpform
import ./scorper/http/httpcore, chronos
import asynctest, strformat

var handler = proc (request: Request) {.closure, async.} =
  let form = await request.form
  doAssert $form is string
  doAssert form.data["UserName"] == "test"
  doAssert form.data["UserNameKana"] == "テスト"
  doAssert form.data["MailAddress"] == "test@example.com"
  await request.resp("Hello World, 200")

proc request(server: Scorper): Future[AsyncResponse] {.async.} =
  let
    client = newAsyncHttpClient()
  var headers = newHttpHeaders([(key: "Content-Type", val: "application/x-www-form-urlencoded")])
  const body = "UserName=test&UserNameKana=%E3%83%86%E3%82%B9%E3%83%88&MailAddress=test%40example.com"
  let testUrl = fmt"http://127.0.0.1:{server.local.port}/foo?bar=qux"
  let clientResponse = await client.request(testUrl, HttpPost, body = body, headers = headers)
  await client.close()

  return clientResponse

var server: Scorper

suite "test url encode":
  setup:
    let address = "127.0.0.1:0"
    let flags = {ReuseAddr}

    server = newScorper(address, handler, flags)
    server.start()

  teardown:
    server.stop()
    server.close()
    await server.join()

  test "url encode":
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
