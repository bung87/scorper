import looper

when isMainModule:
  type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}
  proc cb(req: Request) {.async.} =
    let headers = {"Content-type": "text/plain; charset=utf-8"}
    await req.resp("Hello World", headers.newHttpHeaders())
  
  let r = newRouter[AsyncCallback]()
  r.addRoute(cb, "get","/")
  r.addRoute(cb, "get","/{p1}/{p2}")
  let address = "127.0.0.1:8888"
  let flags = {ReuseAddr}
  var server = newLooper(address,r,flags)
  server.start()
  waitFor server.join()
