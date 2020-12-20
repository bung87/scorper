import osproc
import os
import strformat
import locks
import strutils

const demoPath = currentSourcePath.parentDir / ".." / "examples" / "hello_world_with_router.nim"
var
  thr: array[3, Thread[void]]
  L: Lock
let n = 5000
let c = 500
let testOptions = {poEvalCommand, poParentStreams}
var pid: int
var projChan: Channel[int]
projChan.open()
var workerChan: Channel[bool]
workerChan.open()
proc proj(){.thread.} =
  let (dir, path, ext) = demoPath.splitFile
  let bin = startProcess(fmt"nim c -d:release {demoPath}", options = {poEvalCommand})
  discard waitForExit(bin)
  let project = startProcess(fmt"{dir / path}", options = {poEvalCommand})
  pid = project.processID
  workerChan.send(true)
  while project.running:
    let tried = projChan.tryRecv()
    if tried.dataAvailable and tried.msg == 2:
      project.terminate
      break

proc root(){.thread.} =
  acquire(L)
  let test = startProcess(fmt"ab -v 1 -n {n} -c {c} -r http://127.0.0.1:8888/", options = testOptions)
  let test1Code = waitForExit(test)
  release(L)
  projChan.send(1)

proc pa(){.thread.} =
  acquire(L)
  let test2 = startProcess(fmt"ab -v 1 -n {n} -c {c} -r http://127.0.0.1:8888/p1/p2", options = testOptions)
  let test2Code = waitForExit(test2)
  release(L)
  projChan.send(2)

initLock(L)
createThread(thr[0], proj)
discard workerChan.recv()
createThread(thr[1], root)
createThread(thr[2], pa)
joinThreads(thr)
deinitLock(L)
workerChan.close
projChan.close
