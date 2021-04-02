import scorper

when isMainModule:
  type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}
  proc cb(req: Request) {.async.} =
    await req.sendFile(currentSourcePath)
  
  let r = newRouter[AsyncCallback]()
  r.addRoute(cb, "get","/sendfile")
  let address = "127.0.0.1:8888"
  let flags = {ReuseAddr}
  var server = newScorper(address,r,flags)
  server.start()
  waitFor server.join()
