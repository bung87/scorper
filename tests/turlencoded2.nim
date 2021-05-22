
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpform
import ./scorper/http/urlly
import ./scorper/http/httpcore, chronos

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Scorper): Future[AsyncResponse]{.raises: [].},
    test: proc (response: AsyncResponse, body: string): Future[void]) {.async.} =

  let address = "127.0.0.1:64124"
  let flags = {ReuseAddr}
  var server: Scorper
  try:
    server = newScorper(address, handler, flags)
  except:
    discard
  server.start()
  let
    response = await(request(server))
    body = await(response.readBody())
  try:
    await test(response, body)
  except:
    discard
  server.stop()
  server.close()
  await server.join()

proc testMultipart() {.async.} =
  proc handler(request: Request) {.async.} =
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
    let clientResponse = await client.request(TestUrl, HttpPost, body = body, headers = headers)
    await client.close()

    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")

  await runTest(handler, request, test)
waitfor(testMultipart())

echo "OK"
