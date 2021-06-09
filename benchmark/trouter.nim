import jester/patterns, tables
import scorper/http/router
import nest
import times
import std/httpcore
import std/uri
let t1 = cpuTime()
for i in 1..1000:
  let f = parsePattern("/@p1/@p2")
  doAssert match(f, "/p1/p2").matched
  let f3 = parsePattern(r"/")
  doAssert(match(f3, r"/").matched)

echo "jester:", cpuTime() - t1

proc testHandler() = discard
block:
  let r = router.newRouter[proc()]()
  r.addRoute(testHandler, "get", "/")
  r.addRoute(testHandler, "get", "/{p1}/{p2}")
  r.compress()
  let t2 = cpuTime()
  for i in 1..1000:
    doAssert r.match("GET", "/").success == true
    doAssert r.match("GET", "/p1/p2").success == true

  echo "router:", cpuTime() - t2

block:
  let r = nest.newRouter[proc()]()
  r.map(testHandler, "get", "/")
  r.map(testHandler, "get", "/{p1}/{p2}")
  r.compress()
  const r1 = parseUri"/"
  const r2 = parseUri"/p1/p2"
  let t2 = cpuTime()
  for i in 1..1000:
    doAssert r.route(HttpGet, r1).status == routingSuccess
    doAssert r.route(HttpGet, r2).status == routingSuccess
  echo "nest router:", cpuTime() - t2
