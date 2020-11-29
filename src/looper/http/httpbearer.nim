import chronos
import streamserver
import ./httpcore
import urlly
import httpform
import strutils
import sequtils
import json

proc bearer*(request:Request, scope = "") {.async.} =
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
  if accessScope != scope:
    let extro = @[ ("error","insufficient_scope") , ("error_description", "The request requires higher privileges than provided by the access token") ]
    await request.respBasicAuth("Bearer", params=extro, code=Http403)
  var validateToken = false
  if validateToken == false:
    let extro = @[ ("error","invalid_token") , ("error_description", "The access token provided is expired, revoked, malformed, or invalid for other reasons") ]
    await request.respBasicAuth("Bearer", params=extro, code=Http401)
  else:
    var headers = newHttpHeaders()
    headers["Content-Type"] = "application/json"
    headers["Cache-Control"] = "no-store"
    headers["Pragma"] = "no-cache"
    let j = %* {
       "access_token":"mF_9.B5f-4.1JqM",
       "token_type":"Bearer",
       "expires_in":3600,
       "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA"
     }
    await request.resp( $j ,headers = headers)

