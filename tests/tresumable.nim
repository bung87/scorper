
import ./scorper/http/streamserver
import ./scorper/http/streamclient
import ./scorper/http/httpcore, chronos
import ./scorper/http/exts/resumable
import os, parseutils, streams
import ./scorper/http/urlly

const TestUrl = "http://127.0.0.1:64124/foo?bar=qux"
const source = staticRead(currentSourcePath.parentDir / "range.txt")
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
    echo request.query
    let resumableKeys = newResumableKeys()
    let total = request.query[resumableKeys.totalChunks]
    var totalChunks: BiggestUInt
    discard parseBiggestUInt(total, totalChunks)
    let current = request.query[resumableKeys.chunkIndex]
    var currentIndex: BiggestUInt
    discard parseBiggestUInt(current, currentIndex)
    let tmpDir = getTempDir()
    let identifier = request.query[resumableKeys.identifier]
    let chunkKey = identifier & "." & $currentIndex

    if fileExists(tmpDir / chunkKey):
      await request.respStatus(Http201)
    else:
      let file = open(tmpDir / chunkKey, fmWrite)
      file.write(await request.body)
      file.close
      await request.respStatus(Http200)
    var i: BiggestUInt = 0
    var complete = true
    while i < totalChunks.BiggestUInt:
      let chunkKey = identifier & "." & $(i+1)
      if not fileExists(tmpDir / chunkKey):
        complete = false
      inc i
    var buffer: array[6, char]
    if complete:
      var totalSize: BiggestUInt
      let tsize = request.query[resumableKeys.totalSize]
      discard parseBiggestUInt(tsize, totalSize)
      let file = newFileStream(tmpDir / identifier, fmWrite)
      var j: BiggestUInt = 0
      while j < totalChunks.BiggestUInt:
        let chunkKey = identifier & "." & $(j+1)
        let s = openFileStream(tmpDir / chunkKey)
        while not s.atEnd:
          let readLen = s.readData(buffer.addr, buffer.len)
          file.writeData(buffer.addr, readLen)
        s.flush
        s.close
        inc j
      file.flush
      file.close
      let filepath = tmpDir / identifier
      let fsize = BiggestUInt(getFileSize(filepath))
      doAssert fileExists(filepath) and fsize == totalSize

  proc request(server: Scorper): Future[void] {.async.} =
    let
      client = newAsyncHttpClient()
    let filename = currentSourcePath.parentDir / "range.txt"
    await client.uploadResumable(filename, TestUrl)
    await client.close()

  runTest(handler, request)

waitfor(testSendFIle())

echo "OK"
