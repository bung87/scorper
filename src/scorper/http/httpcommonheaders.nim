## generated through ./httpcore
{.push hint[Name]: off.}
import ./httptypes
import tables

proc Accept*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Accept"] = @[value]

proc Accept*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Accept"] = value
  else:
    headers.table.del("Accept")

proc Accept*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Accept"):
    return headers.table["Accept"].HttpHeaderValues


proc WWWAuthenticate*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Www-Authenticate"] = @[value]

proc WWWAuthenticate*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Www-Authenticate"] = value
  else:
    headers.table.del("Www-Authenticate")

proc WWWAuthenticate*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Www-Authenticate"):
    return headers.table["Www-Authenticate"].HttpHeaderValues


proc XFrameOptions*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["X-Frame-Options"] = @[value]

proc XFrameOptions*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["X-Frame-Options"] = value
  else:
    headers.table.del("X-Frame-Options")

proc XFrameOptions*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("X-Frame-Options"):
    return headers.table["X-Frame-Options"].HttpHeaderValues


proc ContentEncoding*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Content-Encoding"] = @[value]

proc ContentEncoding*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Content-Encoding"] = value
  else:
    headers.table.del("Content-Encoding")

proc ContentEncoding*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Content-Encoding"):
    return headers.table["Content-Encoding"].HttpHeaderValues


proc LastModified*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Last-Modified"] = @[value]

proc LastModified*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Last-Modified"] = value
  else:
    headers.table.del("Last-Modified")

proc LastModified*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Last-Modified"):
    return headers.table["Last-Modified"].HttpHeaderValues


proc AcceptRanges*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Accept-Ranges"] = @[value]

proc AcceptRanges*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Accept-Ranges"] = value
  else:
    headers.table.del("Accept-Ranges")

proc AcceptRanges*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Accept-Ranges"):
    return headers.table["Accept-Ranges"].HttpHeaderValues


proc AcceptCharset*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Accept-Charset"] = @[value]

proc AcceptCharset*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Accept-Charset"] = value
  else:
    headers.table.del("Accept-Charset")

proc AcceptCharset*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Accept-Charset"):
    return headers.table["Accept-Charset"].HttpHeaderValues


proc AcceptEncoding*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Accept-Encoding"] = @[value]

proc AcceptEncoding*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Accept-Encoding"] = value
  else:
    headers.table.del("Accept-Encoding")

proc AcceptEncoding*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Accept-Encoding"):
    return headers.table["Accept-Encoding"].HttpHeaderValues


proc AcceptLanguage*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Accept-Language"] = @[value]

proc AcceptLanguage*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Accept-Language"] = value
  else:
    headers.table.del("Accept-Language")

proc AcceptLanguage*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Accept-Language"):
    return headers.table["Accept-Language"].HttpHeaderValues


proc AcceptDatetime*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Accept-Datetime"] = @[value]

proc AcceptDatetime*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Accept-Datetime"] = value
  else:
    headers.table.del("Accept-Datetime")

proc AcceptDatetime*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Accept-Datetime"):
    return headers.table["Accept-Datetime"].HttpHeaderValues


proc Authorization*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Authorization"] = @[value]

proc Authorization*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Authorization"] = value
  else:
    headers.table.del("Authorization")

proc Authorization*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Authorization"):
    return headers.table["Authorization"].HttpHeaderValues


proc CacheControl*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Cache-Control"] = @[value]

proc CacheControl*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Cache-Control"] = value
  else:
    headers.table.del("Cache-Control")

proc CacheControl*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Cache-Control"):
    return headers.table["Cache-Control"].HttpHeaderValues


proc Server*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Server"] = @[value]

proc Server*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Server"] = value
  else:
    headers.table.del("Server")

proc Server*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Server"):
    return headers.table["Server"].HttpHeaderValues


proc Connection*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Connection"] = @[value]

proc Connection*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Connection"] = value
  else:
    headers.table.del("Connection")

proc Connection*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Connection"):
    return headers.table["Connection"].HttpHeaderValues


proc Cookie*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Cookie"] = @[value]

proc Cookie*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Cookie"] = value
  else:
    headers.table.del("Cookie")

proc Cookie*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Cookie"):
    return headers.table["Cookie"].HttpHeaderValues


proc ContentLength*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Content-Length"] = @[value]

proc ContentLength*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Content-Length"] = value
  else:
    headers.table.del("Content-Length")

proc ContentLength*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Content-Length"):
    return headers.table["Content-Length"].HttpHeaderValues


proc ContentMD5*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Content-Md5"] = @[value]

proc ContentMD5*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Content-Md5"] = value
  else:
    headers.table.del("Content-Md5")

proc ContentMD5*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Content-Md5"):
    return headers.table["Content-Md5"].HttpHeaderValues


proc ContentType*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Content-Type"] = @[value]

proc ContentType*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Content-Type"] = value
  else:
    headers.table.del("Content-Type")

proc ContentType*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Content-Type"):
    return headers.table["Content-Type"].HttpHeaderValues


proc Date*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Date"] = @[value]

proc Date*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Date"] = value
  else:
    headers.table.del("Date")

proc Date*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Date"):
    return headers.table["Date"].HttpHeaderValues


proc Expect*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Expect"] = @[value]

proc Expect*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Expect"] = value
  else:
    headers.table.del("Expect")

proc Expect*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Expect"):
    return headers.table["Expect"].HttpHeaderValues


proc From*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["From"] = @[value]

proc From*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["From"] = value
  else:
    headers.table.del("From")

proc From*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("From"):
    return headers.table["From"].HttpHeaderValues


proc Host*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Host"] = @[value]

proc Host*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Host"] = value
  else:
    headers.table.del("Host")

proc Host*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Host"):
    return headers.table["Host"].HttpHeaderValues


proc IfMatch*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["If-Match"] = @[value]

proc IfMatch*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["If-Match"] = value
  else:
    headers.table.del("If-Match")

proc IfMatch*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("If-Match"):
    return headers.table["If-Match"].HttpHeaderValues


proc IfModifiedSince*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["If-Modified-Since"] = @[value]

proc IfModifiedSince*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["If-Modified-Since"] = value
  else:
    headers.table.del("If-Modified-Since")

proc IfModifiedSince*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("If-Modified-Since"):
    return headers.table["If-Modified-Since"].HttpHeaderValues


proc IfNoneMatch*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["If-None-Match"] = @[value]

proc IfNoneMatch*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["If-None-Match"] = value
  else:
    headers.table.del("If-None-Match")

proc IfNoneMatch*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("If-None-Match"):
    return headers.table["If-None-Match"].HttpHeaderValues


proc IfRange*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["If-Range"] = @[value]

proc IfRange*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["If-Range"] = value
  else:
    headers.table.del("If-Range")

proc IfRange*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("If-Range"):
    return headers.table["If-Range"].HttpHeaderValues


proc IfUnmodifiedSince*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["If-Unmodified-Since"] = @[value]

proc IfUnmodifiedSince*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["If-Unmodified-Since"] = value
  else:
    headers.table.del("If-Unmodified-Since")

proc IfUnmodifiedSince*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("If-Unmodified-Since"):
    return headers.table["If-Unmodified-Since"].HttpHeaderValues


proc MaxForwards*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Max-Forwards"] = @[value]

proc MaxForwards*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Max-Forwards"] = value
  else:
    headers.table.del("Max-Forwards")

proc MaxForwards*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Max-Forwards"):
    return headers.table["Max-Forwards"].HttpHeaderValues


proc Pragma*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Pragma"] = @[value]

proc Pragma*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Pragma"] = value
  else:
    headers.table.del("Pragma")

proc Pragma*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Pragma"):
    return headers.table["Pragma"].HttpHeaderValues


proc ProxyAuthorization*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Proxy-Authorization"] = @[value]

proc ProxyAuthorization*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Proxy-Authorization"] = value
  else:
    headers.table.del("Proxy-Authorization")

proc ProxyAuthorization*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Proxy-Authorization"):
    return headers.table["Proxy-Authorization"].HttpHeaderValues


proc Range*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Range"] = @[value]

proc Range*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Range"] = value
  else:
    headers.table.del("Range")

proc Range*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Range"):
    return headers.table["Range"].HttpHeaderValues


proc Referer*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Referer"] = @[value]

proc Referer*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Referer"] = value
  else:
    headers.table.del("Referer")

proc Referer*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Referer"):
    return headers.table["Referer"].HttpHeaderValues


proc TE*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Te"] = @[value]

proc TE*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Te"] = value
  else:
    headers.table.del("Te")

proc TE*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Te"):
    return headers.table["Te"].HttpHeaderValues


proc Upgrade*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Upgrade"] = @[value]

proc Upgrade*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Upgrade"] = value
  else:
    headers.table.del("Upgrade")

proc Upgrade*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Upgrade"):
    return headers.table["Upgrade"].HttpHeaderValues


proc UserAgent*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["User-Agent"] = @[value]

proc UserAgent*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["User-Agent"] = value
  else:
    headers.table.del("User-Agent")

proc UserAgent*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("User-Agent"):
    return headers.table["User-Agent"].HttpHeaderValues


proc Via*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Via"] = @[value]

proc Via*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Via"] = value
  else:
    headers.table.del("Via")

proc Via*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Via"):
    return headers.table["Via"].HttpHeaderValues


proc Warning*(headers: HttpHeaders, value: string) {.inline.} =
  headers.table["Warning"] = @[value]

proc Warning*(headers: HttpHeaders, value: seq[string]) {.inline.} =
  if value.len > 0:
    headers.table["Warning"] = value
  else:
    headers.table.del("Warning")

proc Warning*(headers: HttpHeaders): HttpHeaderValues {.inline.} =
  if headers.table.hasKey("Warning"):
    return headers.table["Warning"].HttpHeaderValues

{.pop.}
