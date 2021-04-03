# scorper  ![Build Status](https://github.com/bung87/scorper/workflows/Test/badge.svg)  


[travis]: https://travis-ci.org/bung87/scorper.svg?branch=master

scorper is a micro and elegant web framework written in Nim  

Build upon [chronos](https://github.com/status-im/nim-chronos.git) and serveral excellent projects.

`scorper` will self contain manageable dependencies source code as much as posibble for accelerating development.  


## Compile flags  

``` nim 
const HttpRequestBufferSize* {.intdefine.} = 2.Kb
const HttpHeadersLength* {.intdefine.} = int(HttpRequestBufferSize / 32) 
# 32 is sizeof MofuHeader
const gzipMinLength* {.intdefine.} = 20
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
- [ ] Better error control flow.  
- [ ] CLI tool generate object oriented controller and routes.  
- [ ] Auto render response respect client accepted content type.  
- [ ] Chuncked file upload handle for large file.  

## Benchmark  

requires `wrk`  

`nimble benchmark`  
`nimble benchmarkserver` 

### Report  
runs on my MBP Dual-Core Intel Core i5 2.7 GHz ,8 GB memory.  
scorper: 1.0.2
chronos: 3.0.1
nim version: 1.5.1, 1.4.4
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

## Limitations  

the `mofuparser` use `SIMD` which relys on cpu support `SSE` or `AVX` instructions  

## License  

Apache License 2.0