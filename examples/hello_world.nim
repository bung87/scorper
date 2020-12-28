import looper
const port{.intdefine.} = 8888
when isMainModule:
  proc cb(req: Request) {.async.} =
    let headers = {"Content-type": "text/plain"}
    await req.resp("Hello, World!", headers.newHttpHeaders())
  let address = "127.0.0.1:" & $port
  waitFor serve(address, cb)
