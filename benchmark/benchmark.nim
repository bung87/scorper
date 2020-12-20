import osproc
import os
import strformat
import locks
import strutils
import cpuinfo,math

let threadsNum = nextPowerOfTwo(cpuinfo.countProcessors())

const port {.intdefine.} = 8888
const demoPath{.strdefine.} = "examples" / "hello_world_with_router.nim"
var
  thr: array[3, Thread[void]]
  L: Lock
let testOptions = {poEvalCommand, poParentStreams}
var pid: int
var projChan: Channel[int]
projChan.open()
var workerChan: Channel[bool]
workerChan.open()
proc proj(){.thread.} =
  let (dir, path, ext) = demoPath.splitFile
  let bin = startProcess(fmt"nim c -d:release -d:port={port} {demoPath}", options = {poEvalCommand})
  discard waitForExit(bin)
  let project = startProcess(fmt"{dir / path}", options = {poEvalCommand})
  pid = project.processID
  workerChan.send(true)
  var total: int
  while project.running:
    let tried = projChan.tryRecv()
    if tried.dataAvailable:
      inc total
    if total == 2:
      project.terminate
      break

proc root(){.thread.} =
  acquire(L)
  let test = startProcess(fmt"wrk -t{threadsNum} -c100 -d30s http://127.0.0.1:{port}/", options = testOptions)
  let test1Code = waitForExit(test)
  projChan.send(1)
  release(L)

proc pa(){.thread.} =
  acquire(L)
  let test2 = startProcess(fmt"wrk -t{threadsNum} -c100 -d30s http://127.0.0.1:{port}/p1/p2", options = testOptions)
  let test2Code = waitForExit(test2)
  projChan.send(2)
  release(L)

initLock(L)
createThread(thr[0], proj)
discard workerChan.recv()
sleep(2000)
createThread(thr[1], root)
createThread(thr[2], pa)
joinThreads(thr)
deinitLock(L)
workerChan.close
projChan.close
