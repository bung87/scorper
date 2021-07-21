from ./http/httprequest import Request
import std/[macros, macrocache]
import chronos
export Request

type MiddlewareProc* = proc (req: Request): Future[bool]

const preProcessMiddlewares = CacheSeq"preProcessMiddlewares"
const postProcessMiddlewares = CacheSeq"postProcessMiddlewares"

macro preMiddleware*(impl: typed): untyped =
  preProcessMiddlewares.add impl
  result = impl

macro postMiddleware*(impl: typed): untyped =
  postProcessMiddlewares.add impl
  result = impl

macro handlePreProcessMiddlewares*(req: untyped): untyped =
  result = newStmtList()
  if preProcessMiddlewares.len > 0:
    var myWhile = nnkWhileStmt.newTree(
      newIdentNode("true")
    )
    for m in preProcessMiddlewares:
      let theCall = newCall(m.name, req)
      myWhile.add nnkIfStmt.newTree(
        nnkElifBranch.newTree(
          nnkPrefix.newTree(
            newIdentNode("not"),
            newCall(ident"await", theCall)
        ),
        nnkStmtList.newTree(
          nnkBreakStmt.newTree(
            newEmptyNode()
          )
        )
      )
      )
    result.add myWhile


macro handlePostProcessMiddlewares*(req: untyped): untyped =
  result = newStmtList()
  if postProcessMiddlewares.len > 0:
    var myWhile = nnkWhileStmt.newTree(
      newIdentNode("true")
    )
    for m in postProcessMiddlewares:
      let theCall = newCall(m.name, req)
      myWhile.add nnkIfStmt.newTree(
        nnkElifBranch.newTree(
          nnkPrefix.newTree(
            newIdentNode("not"),
            newCall(ident"await", theCall)
        ),
        nnkStmtList.newTree(
          nnkBreakStmt.newTree(
            newEmptyNode()
          )
        )
      )
      )
    result.add myWhile
