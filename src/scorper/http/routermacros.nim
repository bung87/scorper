import chronos
import streamserver, router, httpcore
import macros
import ../private/pnode_parse
import strutils,sequtils,sugar
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

proc collectImps(n:PNode,o:var seq[PNode]) =
  if n.kind == nkImportStmt:
    o.add n
  for m in n:
    collectImps(m,o)

proc `$`*(node: PNode): string =
  ## Get the string of an identifier node.
  case node.kind
  of nkPostfix, nkInfix:
    result = $node[0].ident.s
  of nkIdent:
    result = $node.ident.s
  of nkPrefix:
    result = $node.ident.s
  of nkStrLit..nkTripleStrLit, nkCommentStmt, nkSym:
    result = node.strVal
  # of nnkOpenSymChoice, nnkClosedSymChoice:
  #   result = $node[0]
  of nkCall:
    result = $node[0].ident.s
  of nkAccQuoted:
    result = $node[0]
  else:
    discard

proc getPath(p:Pnode):string =
  case p.kind
  of nkPrefix:
    return p.sons.mapIt($it).join("")
  of nkInfix:
    return ""
  else:
    return ""
    # return p.sons.mapIt(it.ident).join("")

template mount*[H](router: Router[H],h:typed) =
  # let cPath = lineInfoObj(h).filename
  let cPath = instantiationInfo(fullPaths=true).filename
  let f = readFile(cPath)
  var imps =  newSeq[PNode]()
  let n = parsePNodeStr(f)
  
  collectImps(n,imps)
  var needAdd = newSeq[PNode]()
  for i in imps:
    # echo  i[^1].kind
    let p = getPath i[^1]
    if p.len > 0:
      let m = parsePNodeStr(readFile os.parentDir(cPath) / os.addFileExt(p,"nim") )
      for x in m.sons:
        if x.kind == nkProcDef:
          let s = collect(newSeq()):
            for y in x.sons:
              echo y.kind
              if y.kind == nkPragma:
                for z in y.sons:
                  if z.kind != nkEmpty:
                    $z
          if "route" in s:
            needAdd.add x[0]
  echo needAdd
  # result = nnkStmtList.newTree()
  for a in needAdd:
    # result.add newCall(ident"addRoute",router,ident($a))
    addRoute(router,ident($a))


when isMainModule:
  proc handler(req: Request) {.route("get", "/one"), async.} = discard
  proc handler2(req: Request) {.route(["get", "post"], "/multi"), async.} = discard
  let r = newRouter[ScorperCallback]()
  r.addRoute(handler)
  r.addRoute(handler2)
