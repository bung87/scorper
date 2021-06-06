
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpform
import ./scorper/http/httpcore, chronos
import os, strutils
import asynctest, strformat

var server{.threadvar.}: Scorper
var client: AsyncHttpClient

suite "test post check":
  setup:
    if server == default(Scorper):
      let address = "127.0.0.1:0"
      server = newScorper(address)
      server.start()
      client = newAsyncHttpClient()
      # we use single client send same form 3 times, the second test's handler does not read http body,
      # see if server handle subsequent request properly
  teardown:
    server.stop()
    server.close()
    await server.join()

  test "testMultipartWithoutParseBody":
    # we dont read request body just respand to client
    proc handler(request: Request) {.async.} =
      await request.resp("Hello World, 200")
    server.setHandler handler
    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      var data = newMultipartData()
      data["author"] = "bung"
      data["uploaded_file"] = ("README.md", "text/markdown", readFile getCurrentDir() / "README.md")
      let clientResponse = await client.post(fmt"http://127.0.0.1:{server.local.port}/", multipart = data)
      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

  test "testMultipart":
    proc handler(request: Request) {.async.} =
      let form = await request.form
      doAssert $form is string
      debugEcho $form
      doAssert form.data["author"] == "bung"
      let x: FormFile = form.files["uploaded_file"]
      let c = open(x.filepath).readAll
      let e = readFile getCurrentDir() / "README.md"
      doAssert c == e
      doAssert x.filename == "README.md"
      await request.resp("Hello World, 200")
    server.setHandler handler
    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      var data = newMultipartData()
      data["author"] = "bung"
      data["uploaded_file"] = ("README.md", "text/markdown", readFile getCurrentDir() / "README.md")
      let clientResponse = await client.post(fmt"http://127.0.0.1:{server.local.port}/", multipart = data)
      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")

