from ./http/httprequest import Request
import std/[macros, macrocache]
export Request

const preProcessMiddlewares = CacheSeq"preProcessMiddlewares"
const postProcessMiddlewares = CacheSeq"postProcessMiddlewares"

macro implPreProcessMiddleware*(impls: untyped): untyped =
  for p in impls:
    preProcessMiddlewares.add p
  result = impls

macro implPostProcessMiddleware*(impls: untyped): untyped =
  for p in impls:
    postProcessMiddlewares.add p
  result = impls

macro handlePostProcessMiddlewares*(req: untyped): untyped =
  result = newStmtList()
  if postProcessMiddlewares.len > 0:
    for m in postProcessMiddlewares:
      result.add newCall(ident"await", newCall(m.name, req))
