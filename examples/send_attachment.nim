import scorper

when isMainModule:
  proc cb(req: Request) {.async.} =
    await req.sendAttachment(currentSourcePath)

  let r = newRouter[ScorperCallback]()
  r.addRoute(cb, "get", "/send_attachment")
  let address = "127.0.0.1:8888"
  let flags = {ReuseAddr}
  var server = newScorper(address, r, flags)
  server.start()
  waitFor server.join()
