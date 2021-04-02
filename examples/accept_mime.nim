import scorper

when isMainModule:
  proc cb(req: Request) {.async.} =
    var headers = newHttpHeaders()
    acceptMime(req, ext, headers):
      case ext
      of "html": await req.resp("Hello World", headers)
      of "txt": await req.resp("Hello World", headers)
      else:
        headers["Content-Type"] = "text/html"
        await req.resp("Hello World", headers)

  let address = "127.0.0.1:8888"
  waitFor serve(address, cb)
