import scorper/scorpermacros
import chronos
const port{.intdefine.} = 8888

implPostProcessMiddleware:
  proc abc(req: Request) {.async.} = debugEcho 233

import scorper

when isMainModule:
  proc cb(req: Request) {.async.} =
    let headers = {"Content-type": "text/plain"}
    await req.resp("Hello, World!", headers.newHttpHeaders())
  const address = "127.0.0.1:" & $port
  waitFor serve(address, cb)
