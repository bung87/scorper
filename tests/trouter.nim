
import ./scorper/http/streamserver
import ./scorper/http/httprequest
import ./scorper/http/streamclient
import ./scorper/http/router
import ./scorper/http/httpcore, chronos
import tables
import asynctest, strformat

suite "test router":
  var server: Scorper
  var client = newAsyncHttpClient()

  var handlerParamRaw = proc (request: Request) {.async.} =
    doAssert request.params["code"] == "ß"
    await request.resp("")

  var handlerParams = proc (request: Request) {.async.} =
    await request.resp($request.params & $request.url.query.toTable)

  var handlerParamsEncode = proc (request: Request) {.async.} =
    doAssert request.params["codex"] == "ß"
    await request.resp("")

  setupAll:
    let address = "127.0.0.1:0"
    let flags = {ReuseAddr}
    let r = newRouter[ScorperCallback]()
    r.addRoute(handlerParams, "get", "/basic/{p1}/{p2}")
    r.addRoute(handlerParamsEncode, "get", "/code/{codex}")
    r.addRoute(handlerParamRaw, "get", "/code_raw/{codex}")
    server = newScorper(address, r, flags)
    server.start()

  teardownAll:
    await client.close()
    server.stop()
    server.close()
    await server.join()

  test "testParams":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      result = await client.request(fmt"http://127.0.0.1:{server.local.port}/basic/foo/ba?q=qux")

    let
      response = await request(server)
      body = await response.readBody()
    doAssert(response.code == Http200)
    let p = {"p1": "foo", "p2": "ba"}.toTable
    let q = {"q": "qux"}.toTable
    doAssert(body == $p & $q)


  test "testParamEncode":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let codeUrl = fmt"http://127.0.0.1:{server.local.port}/code/%C3%9F"
      result = await client.request(codeUrl)

    let
      response = await request(server)
    doAssert(response.code == Http200)


  test "testParamRaw":

    proc request(server: Scorper): Future[AsyncResponse] {.async.} =
      let codeUrl = fmt"http://127.0.0.1:{server.local.port}/code_raw/ß"
      result = await client.request(codeUrl)

    let
      response = await request(server)
    doAssert(response.code == Http404)

