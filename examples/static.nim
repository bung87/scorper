import looper

when isMainModule:
  type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe.}

  let r = newRouter[AsyncCallback]()
  r.addRoute(serveStatic, "get", "/static/*$")
  let address = "127.0.0.1:8888"
  echo "check " & "http://127.0.0.1:8888/static/README.md"
  let flags = {ReuseAddr}
  var server = newLooper(address, r, flags)
  server.start()
  waitFor server.join()
