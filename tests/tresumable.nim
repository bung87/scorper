
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import ./scorper/http/exts/resumable
import os, parseutils, streams
import ./scorper/http/urlly
import results

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"
const filename = currentSourcePath.parentDir / "range.txt"
const source = staticRead(filename)

proc runTest(
    handler: proc (request: Request): Future[void] {.gcsafe.},
    request: proc (server: Scorper): Future[void]) =

  let address = "127.0.0.1:64124"
  let flags = {ReuseAddr}
  var server = newScorper(address, handler, flags)
  server.start()
  waitFor(request(server))
  server.stop()
  server.close()
  waitFor server.join()

proc testSendFIle() {.async.} =
  proc handler(request: Request) {.async.} =
    let r = await request.handleResumableUpload()
    if r.isOk:
      echo "handleResumableUpload success"
      let resumable = r.get
      if resumable.savePath.len > 0:
        echo "resumable.savePath: " & resumable.savePath
        doAssert getFileSize(resumable.savePath) == source.len
    else:
      echo "handleResumableUpload fails"
  proc request(server: Scorper): Future[void] {.async.} =
    let
      client = newAsyncHttpClient()

    await client.uploadResumable(filename, TestUrl)
    await client.close()
  try:
    runTest(handler, request)
  except:
    discard

waitfor(testSendFIle())

echo "OK"
