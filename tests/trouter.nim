
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/router
import ./scorper/http/httpcore, chronos
import tables
import asynctest, strformat

const TestUrl = "http://127.0.0.1:64124/basic/foo/ba?q=qux"
type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}

var server: Scorper

var handlerParamRaw = proc (request: Request) {.async.} =
  doAssert request.params["code"] == "ß"
  await request.resp("")

var handlerParams = proc (request: Request) {.async.} =
  await request.resp($request.params & $request.query.toTable)

var handlerParamsEncode = proc (request: Request) {.async.} =
  doAssert request.params["codex"] == "ß"
  await request.resp("")

suite "test serve static file":
  setup:
    let address = "127.0.0.1:0"
    let flags = {ReuseAddr}
    let r = newRouter[AsyncCallback]()
    r.addRoute(handlerParams, "get", "/basic/{p1}/{p2}")
    r.addRoute(handlerParamsEncode, "get", "/code/{codex}")
    r.addRoute(handlerParamRaw, "get", "/code_raw/{codex}")
    server = newScorper(address, r, flags)
    server.start()

  teardown:
    server.stop()
    server.close()
    await server.join()

  test "testParams":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let
        client = newAsyncHttpClient()
        clientResponse = await client.request(fmt"http://127.0.0.1:{server.local.port}/basic/foo/ba?q=qux")
      await client.close()

      return clientResponse
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    let p = {"p1": "foo", "p2": "ba"}.toTable
    let q = {"q": "qux"}.toTable
    doAssert(body == $p & $q)


  test "testParamEncode":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let
        client = newAsyncHttpClient()
        codeUrl = fmt"http://127.0.0.1:{server.local.port}/code/%C3%9F"
        clientResponse = await client.request(codeUrl)
      await client.close()

      return clientResponse
    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)


  test "testParamRaw":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let
        client = newAsyncHttpClient()
        codeUrl = fmt"http://127.0.0.1:{server.local.port}/code_raw/ß"
        clientResponse = await client.request(codeUrl)
      await client.close()

      return clientResponse
    let
      response = await request(server)
    doAssert(response.code == Http404)

