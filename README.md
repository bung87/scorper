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
```
Running 30s test @ http://127.0.0.1:8888/
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     5.00ms    2.87ms  84.54ms   96.99%
    Req/Sec     5.11k   757.13     6.55k    74.75%
  610863 requests in 30.06s, 66.99MB read
Requests/sec:  20322.20
Transfer/sec:      2.23MB
```
### Conclusion
*qps* thousands faster than `jester` with stdlib.  it even thousand faster than `asynchttpserver`

## Limitations  

the `mofuparser` use `SIMD` which relys on cpu support `SSE` or `AVX` instructions  

## License  

Apache License 2.0