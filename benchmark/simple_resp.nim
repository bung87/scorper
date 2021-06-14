import std / [exitprocs]
import scorper
import jsony

const port {.intdefine.} = 8080

type Resp = object
  message: string

proc jsonHandler(req: Request) {.route("get", "/json"), async.} =
  let headers = {"Content-type": "application/json"}
  await req.resp(Resp(message: "Hello, World!").toJson(), @headers)

proc plaintextHandler(req: Request) {.route("get", "/plaintext"), async.} =
  let headers = {"Content-type": "text/plain"}
  await req.resp("Hello, World!", @headers)

when isMainModule:

  let address = "0.0.0.0:" & $port
  let flags = {ReuseAddr}
  let r = newRouter[ScorperCallback]()
  r.addRoute(jsonHandler)
  r.addRoute(plaintextHandler)
  var server = newScorper(address, r, flags)
  exitprocs.addExitProc proc() = server.stop(); waitFor server.closeWait()
  server.start()

  waitFor server.join()
