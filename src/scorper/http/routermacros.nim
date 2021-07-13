import chronos
import streamserver, router, httpcore
import macros
import ../private/pnode_parse
import strutils, sequtils, sugar
import os

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

proc collectImps(n: PNode, o: var seq[PNode]) =
  if n.kind == nkImportStmt:
    o.add n
  for m in n:
    collectImps(m, o)

proc `$`*(node: PNode): string =
  ## Get the string of an identifier node.
  case node.kind
  of nkInfix:
    result = $node[0].ident.s
  of nkIdent:
    result = $node.ident.s
  of nkPrefix:
    result = $node.ident.s
  of nkStrLit..nkTripleStrLit, nkCommentStmt, nkSym:
    result = node.strVal
  of nkPostfix:
    result = $node[1].ident.s
  of nkCall:
    result = $node[0].ident.s
  of nkAccQuoted:
    result = $node[0]
  else:
    discard

proc getPath(p: Pnode): string =
  case p.kind
  of nkPrefix:
    return p.sons.mapIt($it).join("")
  of nkInfix:
    return ""
  else:
    return ""
    # return p.sons.mapIt(it.ident).join("")


proc getRoutes(cPath: string, r: var seq[string]) =
  let m = parsePNodeStr(readFile cPath)
  for x in m.sons:
    if x.kind == nkProcDef:
      let s = collect(newSeq):
        for y in x.sons:
          if y.kind == nkPragma:
            for z in y.sons:
              if z.kind != nkEmpty:
                $z
      if "route" in s:
        r.add $x[0]

proc getImports(cPath: string): seq[string] =
  let f = readFile(cPath)
  var imps = newSeq[PNode]()
  let n = parsePNodeStr(f)
  collectImps(n, imps)
  for i in imps:
    let p = getPath i[^1]
    if p.len > 0:
      let cp = os.parentDir(cPath) / os.addFileExt(p, "nim")
      getRoutes(cp, result)

macro mount*[H](router: Router[H], h: untyped) =
  let cPath = lineInfoObj(h).filename
  let cmd = "routermacros"
  let r = staticExec(cmd & " " & cPath)
  let routes = r.split(",")
  result = nnkStmtList.newTree()
  for a in routes:
    result.add newCall(ident"addRoute", router, ident(a))

when isMainModule:
  when declared(commandLineParams):
    var f = paramStr(1)
    f.normalizePath
    let r = getImports(f.absolutePath)
    stdout.write(r.join(","))
  else:
    proc handler(req: Request) {.route("get", "/one"), async.} = discard
    proc handler2(req: Request) {.route(["get", "post"], "/multi"), async.} = discard
    let r = newRouter[ScorperCallback]()
    r.addRoute(handler)
    r.addRoute(handler2)
