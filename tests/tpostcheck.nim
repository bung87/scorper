
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpform
import ./scorper/http/httpcore, chronos
import os, strutils

const TestUrl = "http://127.0.0.1:64125/foo?bar=qux"

var server{.threadvar.}: Scorper

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Scorper): Future[AsyncResponse]{.raises: [].},
    test: proc (response: AsyncResponse, body: string): Future[void]) {.async.} =
  try:
    server.setHandler handler
  except:
    discard
  let
    response = await(request(server))
    body = await(response.readBody())
  try:
    await test(response, body)
  except:
    discard

proc testMultipartWithoutParseBody(client: AsyncHttpClient) {.async.} =
  # we dont read request body just respand to client
  proc handler(request: Request) {.async.} =
    await request.resp("Hello World, 200")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    var data = newMultipartData()
    data["author"] = "bung"
    data["uploaded_file"] = ("README.md", "text/markdown", readFile getCurrentDir() / "README.md")
    let clientResponse = await client.post(TestUrl, multipart = data)
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  await runTest(handler, request, test)


proc testMultipart(client: AsyncHttpClient) {.async.} =
  proc handler(request: Request) {.async.} =
    let form = await request.form
    doAssert $form is string
    echo $form
    doAssert form.data["author"] == "bung"
    let x: FormFile = form.files["uploaded_file"]
    let c = open(x.filepath).readAll
    let e = readFile getCurrentDir() / "README.md"
    doAssert c == e
    doAssert x.filename == "README.md"
    await request.resp("Hello World, 200")

  proc request(server: Scorper): Future[AsyncResponse] {.async.} =
    var data = newMultipartData()
    data["author"] = "bung"
    data["uploaded_file"] = ("README.md", "text/markdown", readFile getCurrentDir() / "README.md")
    let clientResponse = await client.post(TestUrl, multipart = data)
    return clientResponse

  proc test(response: AsyncResponse, body: string) {.async.} =
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  await runTest(handler, request, test)

let address = "127.0.0.1:64125"
let flags: set[ServerFlags] = {ReuseAddr, ReusePort}

server = newScorper(address, flags)
server.start()
let
  client = newAsyncHttpClient()

waitfor(testMultipart(client))

# we use single client send same form 3 times, the second test's handler does not read http body,
# see if server handle subsequent request properly
waitfor(testMultipartWithoutParseBody(client))

waitfor(testMultipart(client))

waitFor client.close()

server.stop()
waitFor server.closeWait()

echo "OK"
