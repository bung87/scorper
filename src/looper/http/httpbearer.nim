import chronos
import streamserver
import ./httpcore
import urlly
import httpform
import strutils
import sequtils
import json

type BearerValidator* = ref object
  validateScope:proc (request: Request, scope:string): Future[tuple[success:bool,content:string]] {.closure, gcsafe.}
  validateToken:proc (request: Request, accessToken:string): Future[tuple[success:bool,content:string]] {.closure, gcsafe.}

type BearerAccessTokenResponse* = ref object
  access_token: string
  expires_in:string
  refresh_token:string
  token_type:string

proc newBearerAccessTokenResponse*(access_token:string,expires_in:int,refresh_token:string):BearerAccessTokenResponse =
  new result
  result.access_token = access_token
  result.expires_in = expires_in
  result.refresh_token = refresh_token
  result.token_type = "Bearer"

proc bearer*(request:Request, validator: BearerValidator): Future[bool] {.async.} =
  # https://tools.ietf.org/html/rfc6750
  var accessToken:string
  var accessScope:string
  if request.meth == HttpGet:
    accessToken = request.query["access_token"]
    accessScope = request.query["scope"]
  elif request.meth == HttpPost:
    let form = await request.form
    accessToken = form.data["access_token"]
    accessScope = form.data["scope"]
  if accessToken.len == 0:
    let extro = @[ ("error","invalid_request") , ("error_description", "access token required") ]
    await request.respBasicAuth("Bearer", params=extro, code=Http400)
    return false
  let r1 = await validator.validateScope(request, accessScope)
  if r1.success == false:
    let content = if r1.content.len > 0 : r1.content else: "The request requires higher privileges than provided by the access token"
    let extro = @[ ("error","insufficient_scope") , ("error_description", content ) ]
    await request.respBasicAuth("Bearer", params=extro, code=Http403)
    return false
  let r2 = await validator.validateToken(request, accessToken)
  if r2.success == false:
    let content = if r2.content.len > 0: r2.content else: "The access token provided is expired, revoked, malformed, or invalid for other reasons"
    let extro = @[ ("error","invalid_token") , ("error_description", content) ]
    await request.respBasicAuth("Bearer", params=extro, code=Http401)
    return false
  else:
    var headers = newHttpHeaders()
    headers["Content-Type"] = "application/json"
    headers["Cache-Control"] = "no-store"
    headers["Pragma"] = "no-cache"
    await request.resp( r2.content ,headers = headers)
    return true

