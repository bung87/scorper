import chronos
import ./scorper/http / [streamserver, router, httpcore,routermacros]
proc handler(req: Request) {.route("get", "/one"), async.} = discard
proc handler2(req: Request) {.route(["get", "post"], "/multi"), async.} = discard