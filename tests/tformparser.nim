
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpform
import ./scorper/http/multipartparser
import ./scorper/http/httpcore, chronos, os
import asynctest, strformat

let Sample = """multipart/form-data;boundary="sample_boundary""""

doAssert parseBoundary(Sample).boundary == "sample_boundary"

var server: Scorper

suite "test form parser":
  setup:
    let address = "127.0.0.1:0"
    let flags = {ReuseAddr}
    server = newScorper(address, flags)
    server.start()

  teardown:
    server.stop()
    server.close()
    await server.join()
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
      let
        client = newAsyncHttpClient()
      var data = newMultipartData()
      data["author"] = "bung"
      data["uploaded_file"] = ("README.md", "text/markdown", readFile getCurrentDir() / "README.md")
      let testUrl = fmt"http://127.0.0.1:{server.local.port}"
      let clientResponse = await client.post(testUrl, multipart = data)
      await client.close()

      return clientResponse

    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    doAssert(body == "Hello World, 200")
    doAssert(response.headers.hasKey("Content-Length"))
    doAssert(response.headers["Content-Length"] == "16")
