import looper

when isMainModule:
  type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}
  proc cb(req: Request) {.async.} =
    echo req.hostname
    echo req.meth
    echo req.headers
    echo req.protocol
    echo req.url
    let headers = {"Date": "Tue, 29 Apr 2014 23:40:08 GMT",
        "Content-type": "text/plain; charset=utf-8"}
    await req.resp("Hello World", headers.newHttpHeaders())
  
  let r = newRouter[AsyncCallback]()
  r.addRoute(cb, "get","/")
  let address = initTAddress("127.0.0.1:8888")
  let flags = {ReuseAddr}
  var server = newLooper(address,r,flags)
  server.start()
  waitFor server.join()
