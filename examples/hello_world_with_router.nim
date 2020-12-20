import looper
const port{.intdefine.} = 8888
when isMainModule:
  type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}
  proc cb(req: Request) {.async.} =
    let headers = {"Content-type": "text/plain"}
    await req.resp("Hello, World!", headers.newHttpHeaders())

  let r = newRouter[AsyncCallback]()
  r.addRoute(cb, "get", "/")
  r.addRoute(cb, "get", "/{p1}/{p2}")
  const address = "127.0.0.1:" & $port
  const flags = {ReuseAddr}
  var server = newLooper(address, r, flags)
  server.start()
  waitFor server.join()
