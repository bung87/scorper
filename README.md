# scorper  ![Build Status](https://github.com/bung87/scorper/workflows/Test/badge.svg)  


[travis]: https://travis-ci.org/bung87/scorper.svg?branch=master

scorper is a micro and elegant web framework written in Nim  

Build upon [chronos](https://github.com/status-im/nim-chronos.git) and serveral excellent projects.

`scorper` will self contain manageable dependencies source code as much as posibble for accelerating development.  

**Notice**: `scorper` heavily relys on `chronos` which use its own `async` macro it will conflicts with std `asyncdispatch`'s `async` macro, check your project dependencies chronos support first.    

## Production 

compile your program with `-d:chronosStrictException` if you dont want any exception crash your program.  for details check chronos's readme [#Error handling](https://github.com/status-im/nim-chronos#error-handling)

## Compile flags  
`-d:ssl`  
then use `newScorper` proc and pass `isSecurity = true`,`privateKey`, `certificate`  

``` nim
const GzipEnable {.booldefine.} = true 
const HttpRequestBufferSize* {.intdefine.} = 2.Kb
const HttpServer {.strdefine.} = "scorper"
const TimeOut {.intdefine.} = 300 # in seconds  
const HttpHeadersLength* {.intdefine.} = int(HttpRequestBufferSize / 32) 
# 32 is sizeof MofuHeader
const gzipMinLength* {.intdefine.} = 20
```

## Usage  
### hello world  

### `serve` with callback  

``` nim
import scorper
const port{.intdefine.} = 8888
when isMainModule:
  proc cb(req: Request) {.async.} =
    let headers = {"Content-type": "text/plain"}
    await req.resp("Hello, World!", headers.newHttpHeaders())
  let address = "127.0.0.1:" & $port
  waitFor serve(address, cb)
```

### `newScorper` with router or callback  

``` nim
when isMainModule:
  let r = newRouter[ScorperCallback]()
  # Relys on `StaticDir` environment variable
  r.addRoute(serveStatic, "get", "/static/*$")
  let address = "127.0.0.1:8888"
  let flags = {ReuseAddr}
  var server = newScorper(address, r, flags)
  server.start()
  waitFor server.join()
``` 

### use `route` pragma
``` nim
proc handler(req: Request) {.route("get","/one"),async.} = discard
proc handler2(req: Request) {.route(["get","post"],"/multi"),async.} = discard
let r = newRouter[ScorperCallback]()
r.addRoute(handler)
r.addRoute(handler2)
```

#### use `route` with `mount` macro  
``` nim
import ./my_controler
let r = newRouter[ScorperCallback]()
r.mount(my_controler)
```  

### responds depends on request mime  
``` nim
import scorper

when isMainModule:
  proc cb(req: Request) {.async.} =
    var headers = newHttpHeaders()
    acceptMime(req, ext, headers):
      case ext
      of "html": await req.resp("Hello World", headers)
      of "txt": await req.resp("Hello World", headers)
      else:
        headers["Content-Type"] = "text/html"
        await req.resp("Hello World", headers)

  let address = "127.0.0.1:8888"
  waitFor serve(address, cb)
```

## Types  
``` nim 
type
  Request* = ref object
    meth*: HttpMethod
    headers*: HttpHeaders
    protocol*: tuple[major, minor: int]
    url*: Url
    path*: string              # http req path
    hostname*: string
    ip*: string
    params*: Table[string, string]
    query*: seq[(string, string)]
  ScorperCallback* = proc (req: Request): Future[void] {.closure, gcsafe.}
  Scorper* = ref object of StreamServer
    # inherited (partial)
    sock*: AsyncFD                # Socket
    local*: TransportAddress      # Address
    status*: ServerStatus         # Current server status
    flags*: set[ServerFlags]      # Flags
    errorCode*: OSErrorCode
```
## Todos  

- [x] Parse http request streamingly.  
- [x] Parse form streamingly and lazyly.  
- [x] Send file and attachement streamingly.  
- [x] Http Basic auth, Bearer auth , Digest auth(planed).  
- [x] Serve static files (env:StaticDir)  
- [x] Parse JSON lazyly.  
- [x] cookies module.  
- [ ] Parse JSON streamingly.  
- [x] Better error control flow.  
- [ ] CLI tool generate object oriented controller and routes.  
- [x] Auto render response respect client accepted content (acceptMime macro)type.  
- [x] Chuncked file upload handle for large file. 
- [x] https support 
- [x] handle Resumable upload

## Contribution  
check Todo list upon and [issues](https://github.com/bung87/scorper/issues)  

clone this repository, run `nimble install stage` , if you already have `stage` installed, run `stage init`  
`stage` is used for integrating with git commit hook, doing checking and code formatting.  

## Benchmark  

requires `wrk`  

`nimble benchmark`  
`nimble benchmarkserver` 

### Report  
runs on my MBP Dual-Core Intel Core i5 2.7 GHz ,8 GB memory.  
scorper: `1.0.2`  
chronos: `3.0.1`  
nim version: `1.5.1`, `1.4.4`  
```
Running 30s test @ http://127.0.0.1:8888/
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.51ms    1.00ms  66.66ms   92.16%
    Req/Sec     7.15k   518.66    10.94k    85.67%
  854619 requests in 30.05s, 93.73MB read
Requests/sec:  28441.14
Transfer/sec:      3.12MB
```
### Conclusion
*qps* almost ten thousands faster than `jester` with stdlib.  it even thousand faster than `asynchttpserver`

## Extro feature or limitations  

the `mofuparser` use `SIMD` which relys on cpu support `SSE` or `AVX` instructions  

## Related projects  

[amysql](https://github.com/bung87/amysql)  Async MySQL Connector write in pure Nim. (support chronos with compile flag `-d:ChronosAsync`)

## License  

Apache License 2.0