
import ./scorper/http/streamserver
import ./scorper/http/httprequest
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import ./scorper/http/exts/resumable
import os, parseutils, streams
import stew/results
import asynctest, strformat

const filename = currentSourcePath.parentDir / "range.txt"
const source = staticRead(filename)


proc request(server: Scorper): Future[void] {.async.} =
  let
    client = newAsyncHttpClient()

  await client.uploadResumable(filename, fmt"http://127.0.0.1:{server.local.port}")
  await client.close()

suite "test handleResumableUpload":
  var server: Scorper

  var handler = proc (request: Request) {.closure, async.} =
    let r = await request.handleResumableUpload()
    if r.isOk:
      debugEcho "handleResumableUpload success"
      let resumable = r.get
      if resumable.savePath.len > 0:
        debugEcho "resumable.savePath: " & resumable.savePath
        doAssert getFileSize(resumable.savePath) == source.len
    else:
      debugEcho "handleResumableUpload fails"

  setup:
    let address = "127.0.0.1:0"
    let flags = {ReuseAddr}
    server = newScorper(address, handler, flags)
    server.start()

  teardown:
    server.stop()
    server.close()
    await server.join()

  test "handleResumableUpload":
    await request(server)

