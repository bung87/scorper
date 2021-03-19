import ./httpcore, strutils
import ./futurestream
import times
import chronos

type
  AsyncResponse* = ref object
    version*: string
    status*: string
    headers*: HttpHeaders
    body: string
    bodyStream*: FutureStream[string]

proc code*(response: AsyncResponse): HttpCode
           {.raises: [ValueError, OverflowDefect].} =
  ## Retrieves the specified response's ``HttpCode``.
  ##
  ## Raises a ``ValueError`` if the response's ``status`` does not have a
  ## corresponding ``HttpCode``.
  return response.status[0 .. 2].parseInt.HttpCode

proc contentType*(response: AsyncResponse): string {.inline.} =
  ## Retrieves the specified response's content type.
  ##
  ## This is effectively the value of the "Content-Type" header.
  response.headers.getOrDefault("content-type")

proc contentLength*(response: AsyncResponse): int =
  ## Retrieves the specified response's content length.
  ##
  ## This is effectively the value of the "Content-Length" header.
  ##
  ## A ``ValueError`` exception will be raised if the value is not an integer.
  var contentLengthHeader = response.headers.getOrDefault("Content-Length")
  result = contentLengthHeader.parseInt()
  doAssert(result >= 0 and result <= high(int32))

proc lastModified*(response: AsyncResponse): DateTime =
  ## Retrieves the specified response's last modified time.
  ##
  ## This is effectively the value of the "Last-Modified" header.
  ##
  ## Raises a ``ValueError`` if the parsing fails or the value is not a correctly
  ## formatted time.
  var lastModifiedHeader = response.headers.getOrDefault("last-modified")
  result = parse(lastModifiedHeader, HttpDateFormat, utc())

proc readBody*(response: AsyncResponse): Future[string] {.async.} =
  ## Reads the response's body and caches it. The read is performed only
  ## once.
  if response.body.len == 0:
    response.body = await readAll(response.bodyStream)
  return response.body
