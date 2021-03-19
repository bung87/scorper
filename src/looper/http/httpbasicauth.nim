import chronos
import streamserver
import ./httpcore
import urlly
import httpform
import strutils
import sequtils
import base64

type HttpBasicAuthValidator* = ref object
  validate: proc (request: Request, user, pass: string): Future[bool] {.closure, gcsafe.}

proc basicAuth*(request: Request, validator: HttpBasicAuthValidator): Future[bool] {.async.} =
  # https://tools.ietf.org/html/rfc2617#section-2
  var success: bool
  var up: seq[string]
  try:
    let authorization = request.headers["Authorization"]
    let s2 = authorization.find("Basic")
    let decoded = base64.decode(authorization[s2+6 .. ^1])
    up = decoded.split(":", 1)
  except:
    await request.respError(Http400, "Authorization header not valid")
    return false
  success = await validator.validate(up[0], up[1])
  if not success:
    await request.respBasicAuth()
    return false
  return true

when isMainModule:
  let s = "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
  let s2 = s.find("Basic")
  let decoded = base64.decode(s[s2+6 .. ^1])
  let up = decoded.split(":", 1)
