import chronos
import streamserver, router, httpcore
import macros

type AsyncCallback = proc (request: Request): Future[void] {.closure, gcsafe, raises: [].}

template route*(meth: typed, pattern: string, headers: HttpHeaders = nil){.pragma.}

template addRoute*[H](
  router: Router[H],
  handler: H) =
  when handler.hasCustomPragma(route):
    let p = handler.getCustomPragmaVal(route)
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
  let r = newRouter[AsyncCallback]()
  r.addRoute(handler)
  r.addRoute(handler2)
