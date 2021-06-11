import chronos
import streamserver, router, httpcore
import macros

template route*(meth: typed, pattern: string, headers: HttpHeaders = nil){.pragma.}

template addRoute*[H](
  router: Router[H],
  handler: H) =
  when macros.hasCustomPragma(handler, route):
    let p = macros.getCustomPragmaVal(handler, route)
    when p.meth is string:
      router.addRoute(handler, p.meth, p.pattern, p.headers)
    else:
      for m in p.meth:
        router.addRoute(handler, m, p.pattern, p.headers)
  else:
    {.error: "handler should has route pragma".}

when isMainModule:
  proc handler(req: Request) {.route("get", "/one"), async.} = discard
  proc handler2(req: Request) {.route(["get", "post"], "/multi"), async.} = discard
  let r = newRouter[ScorperCallback]()
  r.addRoute(handler)
  r.addRoute(handler2)
