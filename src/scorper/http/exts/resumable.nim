import ../ httprequest
from ../ streamserver import respStatus, stream, len, toImpRequest
import ../ httpcore
import std / [os, streams, json, parseutils, strutils, sequtils]
import results
import chronos
import urlly

type ResumableKeys* = object
  chunkIndex*: string  # starts with 1
  chunkSize*: string
  currentChunkSize*: string
  totalSize*: string
  identifier*: string
  filename*: string
  relativePath*: string
  totalChunks*: string # Positive

type
  Resumable* = object
    chunkIndex*: BiggestUInt # starts with 1
    chunkSize*: BiggestUInt
    currentChunkSize*: BiggestUInt
    totalSize*: BiggestUInt
    identifier*: string
    filename*: string
    relativePath*: string
    totalChunks*: BiggestUInt
    tmpDir*: string          # server use
    savePath*: string        # server use
  ResumableResult* = Result[Resumable, string]

proc newResumableKeys*(chunkIndex = "flowChunkIndex", chunkSize = "flowChunkSize",
    currentChunkSize = "flowCurrentChunkSize", totalSize = "flowTotalSize", identifier = "flowIdentifier",
    filename = "flowFilename", relativePath = "flowRelativePath", totalChunks = "flowTotalChunks"): ResumableKeys =
  result.chunkIndex = chunkIndex
  result.chunkSize = chunkSize
  result.currentChunkSize = currentChunkSize
  result.totalSize = totalSize
  result.identifier = identifier
  result.filename = filename
  result.relativePath = relativePath
  result.totalChunks = totalChunks

proc isComplete*(resumable: Resumable): bool =
  var i: BiggestUInt = 0
  var complete = true
  while i < resumable.totalChunks:
    let chunkKey = resumable.identifier & "." & $(i+1)
    if not fileExists(resumable.tmpDir / chunkKey):
      complete = false
    inc i
  return complete

proc handleResumableUpload*(req: Request; resumableKeys = newResumableKeys()): Future[ResumableResult]{.async.} =
  template resumableParam(key: untyped): untyped =
    req.query[resumableKeys.`key`]

  var resumable: Resumable
  discard parseBiggestUInt(resumableParam(totalChunks), resumable.totalChunks)
  discard parseBiggestUInt(resumableParam(chunkIndex), resumable.chunkIndex)
  discard parseBiggestUInt(resumableParam(currentChunkSize), resumable.currentChunkSize)
  discard parseBiggestUInt(resumableParam(totalSize), resumable.totalSize)
  resumable.identifier = resumableParam(identifier)
  let tmpDir = getTempDir()
  resumable.tmpDir = tmpDir
  let chunkKey = resumable.identifier & "." & $resumable.chunkIndex
  const bufSize = 8192
  var buffer: array[bufSize, char]
  if fileExists(tmpDir / chunkKey):
    await req.respStatus(Http201)
  else:
    let file = open(tmpDir / chunkKey, fmWrite)
    let stream = req.stream()
    var nbytes: int
    var reads: BiggestUInt
    while not stream.atEof():
      if reads == req.len:
        break
      if reads == resumable.currentChunkSize:
        break
      nbytes = await stream.readOnce(buffer[0].addr, buffer.len)
      reads.inc nbytes
      discard file.writeBuffer(buffer[0].addr, nbytes)
    file.close
    await req.respStatus(Http200)

  let complete = resumable.isComplete()
  if complete:

    let file = newFileStream(tmpDir / resumable.identifier, fmWrite)
    var j: BiggestUInt = 0
    while j < resumable.totalChunks:
      let chunkKey = resumable.identifier & "." & $(j+1)
      let s = openFileStream(tmpDir / chunkKey)
      while not s.atEnd:
        let readLen = s.readData(buffer.addr, buffer.len)
        file.writeData(buffer.addr, readLen)
      s.flush
      try:
        s.close
      except:
        discard
      inc j
    file.flush
    try:
      file.close
    except:
      discard
    let filepath = tmpDir / resumable.identifier
    resumable.savePath = filepath
    when not defined(release):
      let fsize = BiggestUInt(getFileSize(filepath))
      assert fileExists(filepath) and fsize == resumable.totalSize
  result.ok resumable

