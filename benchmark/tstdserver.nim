import asynchttpserver, asyncdispatch
import looper/http/httpdate
const port{.intdefine.} = 8888

proc main {.async.} =
  var server = newAsyncHttpServer()
  proc cb(req: Request) {.async.} =
    let headers = {"Date": httpDate(), "Content-Type": "text/plain"}
    await req.respond(Http200, "Hello, World!", headers.newHttpHeaders())
  
  discard server.serve(Port(port), cb)

asyncCheck main()
runForever()