import scorper
const port{.intdefine.} = 8888
when isMainModule:
  proc cb(req: Request) {.async.} =
    const headers = {"Content-type": "text/plain"}
    await req.resp("Hello, World!", headers.newHttpHeaders())

  let r = newRouter[ScorperCallback]()
  r.addRoute(cb, "get", "/")
  r.addRoute(cb, "get", "/{p1}/{p2}")
  const address = "127.0.0.1:" & $port
  const flags = {ReuseAddr}
  var server = newScorper(address, r, flags)
  server.start()
  waitFor server.join()
