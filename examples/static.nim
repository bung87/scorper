import scorper

when isMainModule:
  # cd `example` dir first then run `nim c -r static.nim`
  let r = newRouter[ScorperCallback]()
  r.addRoute(serveStatic, "get", "/static/*$")
  let address = "127.0.0.1:8888"
  echo "check " & "http://127.0.0.1:8888/static/hello_world.txt"
  let flags = {ReuseAddr}
  var server = newScorper(address, r, flags)
  server.start()
  waitFor server.join()
