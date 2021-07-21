from ./http/httprequest import Request
import std/[macros, macrocache]
export Request

type MiddlewareKind* = enum
  pre, post

const preProcessMiddlewares = CacheSeq"preProcessMiddlewares"
const postProcessMiddlewares = CacheSeq"postProcessMiddlewares"

macro preMiddleware*(impl: untyped): untyped =
  preProcessMiddlewares.add impl
  result = impl

macro postMiddleware*(impl: untyped): untyped =
  postProcessMiddlewares.add impl
  result = impl

macro handlePostProcessMiddlewares*(req: untyped): untyped =
  result = newStmtList()
  if postProcessMiddlewares.len > 0:
    for m in postProcessMiddlewares:
      result.add newCall(ident"await", newCall(m.name, req))
