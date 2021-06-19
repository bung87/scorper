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

macro regRoute*(prc: untyped) =
  result = newStmtList()
  var n = prc[0]
  let
    router = genSym(nskVar, "router")
    mount = ident("mount")
  result.add quote do:
    var `router`{.compileTime.}: seq[NimNode]

  result.add quote do:
    `prc`
    `router`.add n

  result.add quote do:
    when not declared(`mount`):
      macro `mount`*(r: untyped) =
        result = newStmtList()
        for sym in `router`:
          result.add newCall("addRoute", r, sym)

when isMainModule:
  proc handler(req: Request) {.route("get", "/one"), regRoute, async.} = discard
  proc handler2(req: Request) {.route(["get", "post"], "/multi"), regRoute, async.} = discard
  let r = newRouter[ScorperCallback]()
  # r.addRoute(handler)
  # r.addRoute(handler2)
  r.mount()
