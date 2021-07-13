import chronos
import streamserver, router, httpcore
import macros
import ../private/pnode_parse
import strutils, sequtils, sugar
import os, osproc

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

proc collectIdents(s: openarray[PNode], a: var string) =
  for n in s:
    if n.kind == nkIdent:
      a.add n.ident.s
    else:
      collectIdents(n.sons, a)

proc `$`*(node: PNode): string =
  ## Get the string of an identifier node.
  case node.kind
  of nkInfix:
    result = $node[0].ident.s
  of nkIdent:
    result = $node.ident.s
  of nkPrefix:
    collectIdents(node.sons, result)
  of nkStrLit..nkTripleStrLit, nkCommentStmt, nkSym:
    result = node.strVal
  of nkPostfix:
    result = $node[1].ident.s
  of nkCall:
    result = $node[0].ident.s
  of nkAccQuoted:
    result = $node[0]
  of nkFromStmt:
    result = $node[0]
  else:
    discard


proc getPaths(p: PNode, pDir: string): seq[string] =
  case p.kind
  of nkPrefix:
    var pa = $p
    return @[if pa.startsWith("./"): unixToNativePath(pDir / pa) else: execCmdEx("nimble" & "--path " & $p.sons[0]).output]
  of nkInfix:
    if p[^1].kind == nkBracket:
      var prefix: string
      collectIdents(p.sons[1].sons[1].sons, prefix)
      if prefix.startsWith("./"):
        prefix = unixToNativePath(pDir / prefix)
      else:
        prefix = execCmdEx("nimble" & "--path " & $p.sons[0]).output
      return p[^1].sons.mapIt(unixToNativePath(prefix / $it))
  else:
    return result


proc getRoutes(cPath: string, r: var seq[string]) =
  if not fileExists(cPath): return
  if cPath.startsWith(currentSourcePath.parentDir.parentDir): return
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

proc getImports*(cPath: string): seq[string] =
  let f = readFile(cPath)
  let pDir = os.parentDir(cPath)
  var imps = newSeq[PNode]()
  let n = parsePNodeStr(f)
  collectImps(n, imps)
  var ps: seq[string]
  for i in imps:
    ps = getPaths(i[^1], pDir)
    for p in ps:
      if p.len > 0:
        let cp = os.addFileExt(p, "nim")
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
    block:
      var f = paramStr(1)
      f.normalizePath
      let r = getImports(f.absolutePath)
      stdout.write(r.join(","))
  else:
    discard
