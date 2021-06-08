## generated through ./httpcore
import ./httptypes
import tables
proc Accept*(headers: HttpHeaders, value: string) =
  headers.table["Accept"] = @[value]

proc Accept*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Accept"] = value
  else:
    headers.table.del("Accept")
proc WWWAuthenticate*(headers: HttpHeaders, value: string) =
  headers.table["Www-Authenticate"] = @[value]

proc WWWAuthenticate*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Www-Authenticate"] = value
  else:
    headers.table.del("Www-Authenticate")
proc XFrameOptions*(headers: HttpHeaders, value: string) =
  headers.table["X-Frame-Options"] = @[value]

proc XFrameOptions*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["X-Frame-Options"] = value
  else:
    headers.table.del("X-Frame-Options")
proc ContentEncoding*(headers: HttpHeaders, value: string) =
  headers.table["Content-Encoding"] = @[value]

proc ContentEncoding*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Content-Encoding"] = value
  else:
    headers.table.del("Content-Encoding")
proc LastModified*(headers: HttpHeaders, value: string) =
  headers.table["Last-Modified"] = @[value]

proc LastModified*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Last-Modified"] = value
  else:
    headers.table.del("Last-Modified")
proc AcceptRanges*(headers: HttpHeaders, value: string) =
  headers.table["Accept-Ranges"] = @[value]

proc AcceptRanges*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Accept-Ranges"] = value
  else:
    headers.table.del("Accept-Ranges")
proc AcceptCharset*(headers: HttpHeaders, value: string) =
  headers.table["Accept-Charset"] = @[value]

proc AcceptCharset*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Accept-Charset"] = value
  else:
    headers.table.del("Accept-Charset")
proc AcceptEncoding*(headers: HttpHeaders, value: string) =
  headers.table["Accept-Encoding"] = @[value]

proc AcceptEncoding*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Accept-Encoding"] = value
  else:
    headers.table.del("Accept-Encoding")
proc AcceptLanguage*(headers: HttpHeaders, value: string) =
  headers.table["Accept-Language"] = @[value]

proc AcceptLanguage*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Accept-Language"] = value
  else:
    headers.table.del("Accept-Language")
proc AcceptDatetime*(headers: HttpHeaders, value: string) =
  headers.table["Accept-Datetime"] = @[value]

proc AcceptDatetime*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Accept-Datetime"] = value
  else:
    headers.table.del("Accept-Datetime")
proc Authorization*(headers: HttpHeaders, value: string) =
  headers.table["Authorization"] = @[value]

proc Authorization*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Authorization"] = value
  else:
    headers.table.del("Authorization")
proc CacheControl*(headers: HttpHeaders, value: string) =
  headers.table["Cache-Control"] = @[value]

proc CacheControl*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Cache-Control"] = value
  else:
    headers.table.del("Cache-Control")
proc Server*(headers: HttpHeaders, value: string) =
  headers.table["Server"] = @[value]

proc Server*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Server"] = value
  else:
    headers.table.del("Server")
proc Connection*(headers: HttpHeaders, value: string) =
  headers.table["Connection"] = @[value]

proc Connection*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Connection"] = value
  else:
    headers.table.del("Connection")
proc Cookie*(headers: HttpHeaders, value: string) =
  headers.table["Cookie"] = @[value]

proc Cookie*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Cookie"] = value
  else:
    headers.table.del("Cookie")
proc ContentLength*(headers: HttpHeaders, value: string) =
  headers.table["Content-Length"] = @[value]

proc ContentLength*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Content-Length"] = value
  else:
    headers.table.del("Content-Length")
proc ContentMD5*(headers: HttpHeaders, value: string) =
  headers.table["Content-Md5"] = @[value]

proc ContentMD5*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Content-Md5"] = value
  else:
    headers.table.del("Content-Md5")
proc ContentType*(headers: HttpHeaders, value: string) =
  headers.table["Content-Type"] = @[value]

proc ContentType*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Content-Type"] = value
  else:
    headers.table.del("Content-Type")
proc Date*(headers: HttpHeaders, value: string) =
  headers.table["Date"] = @[value]

proc Date*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Date"] = value
  else:
    headers.table.del("Date")
proc Expect*(headers: HttpHeaders, value: string) =
  headers.table["Expect"] = @[value]

proc Expect*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Expect"] = value
  else:
    headers.table.del("Expect")
proc From*(headers: HttpHeaders, value: string) =
  headers.table["From"] = @[value]

proc From*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["From"] = value
  else:
    headers.table.del("From")
proc Host*(headers: HttpHeaders, value: string) =
  headers.table["Host"] = @[value]

proc Host*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Host"] = value
  else:
    headers.table.del("Host")
proc IfMatch*(headers: HttpHeaders, value: string) =
  headers.table["If-Match"] = @[value]

proc IfMatch*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["If-Match"] = value
  else:
    headers.table.del("If-Match")
proc IfModifiedSince*(headers: HttpHeaders, value: string) =
  headers.table["If-Modified-Since"] = @[value]

proc IfModifiedSince*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["If-Modified-Since"] = value
  else:
    headers.table.del("If-Modified-Since")
proc IfNoneMatch*(headers: HttpHeaders, value: string) =
  headers.table["If-None-Match"] = @[value]

proc IfNoneMatch*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["If-None-Match"] = value
  else:
    headers.table.del("If-None-Match")
proc IfRange*(headers: HttpHeaders, value: string) =
  headers.table["If-Range"] = @[value]

proc IfRange*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["If-Range"] = value
  else:
    headers.table.del("If-Range")
proc IfUnmodifiedSince*(headers: HttpHeaders, value: string) =
  headers.table["If-Unmodified-Since"] = @[value]

proc IfUnmodifiedSince*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["If-Unmodified-Since"] = value
  else:
    headers.table.del("If-Unmodified-Since")
proc MaxForwards*(headers: HttpHeaders, value: string) =
  headers.table["Max-Forwards"] = @[value]

proc MaxForwards*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Max-Forwards"] = value
  else:
    headers.table.del("Max-Forwards")
proc Pragma*(headers: HttpHeaders, value: string) =
  headers.table["Pragma"] = @[value]

proc Pragma*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Pragma"] = value
  else:
    headers.table.del("Pragma")
proc ProxyAuthorization*(headers: HttpHeaders, value: string) =
  headers.table["Proxy-Authorization"] = @[value]

proc ProxyAuthorization*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Proxy-Authorization"] = value
  else:
    headers.table.del("Proxy-Authorization")
proc Range*(headers: HttpHeaders, value: string) =
  headers.table["Range"] = @[value]

proc Range*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Range"] = value
  else:
    headers.table.del("Range")
proc Referer*(headers: HttpHeaders, value: string) =
  headers.table["Referer"] = @[value]

proc Referer*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Referer"] = value
  else:
    headers.table.del("Referer")
proc TE*(headers: HttpHeaders, value: string) =
  headers.table["Te"] = @[value]

proc TE*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Te"] = value
  else:
    headers.table.del("Te")
proc Upgrade*(headers: HttpHeaders, value: string) =
  headers.table["Upgrade"] = @[value]

proc Upgrade*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Upgrade"] = value
  else:
    headers.table.del("Upgrade")
proc UserAgent*(headers: HttpHeaders, value: string) =
  headers.table["User-Agent"] = @[value]

proc UserAgent*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["User-Agent"] = value
  else:
    headers.table.del("User-Agent")
proc Via*(headers: HttpHeaders, value: string) =
  headers.table["Via"] = @[value]

proc Via*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Via"] = value
  else:
    headers.table.del("Via")
proc Warning*(headers: HttpHeaders, value: string) =
  headers.table["Warning"] = @[value]

proc Warning*(headers: HttpHeaders, value: seq[string]) =
  if value.len > 0:
    headers.table["Warning"] = value
  else:
    headers.table.del("Warning")
