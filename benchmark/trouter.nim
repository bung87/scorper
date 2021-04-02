import jester/patterns, tables
import scorper/http/router

import times
let t1 = cpuTime()
for i in 1..1000:
  let f = parsePattern("/@p1/@p2")
  doAssert match(f, "/p1/p2").matched
  let f3 = parsePattern(r"/")
  doAssert(match(f3, r"/").matched)

echo cpuTime() - t1

proc testHandler() = echo "test"

let r = newRouter[proc()]()
r.addRoute(testHandler, "get", "/")
r.addRoute(testHandler, "get", "/{p1}/{p2}")
let t2 = cpuTime()
for i in 1..1000:
  doAssert r.match("GET", "/").handler == testHandler
  doAssert r.match("GET", "/p1/p2").handler == testHandler

echo cpuTime() - t2
