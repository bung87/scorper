# Looper  ![Build Status](https://github.com/bung87/Looper/workflows/Test/badge.svg) [![Build Status](travis)](https://travis-ci.org/bung87/Looper)  


[travis]: https://travis-ci.org/bung87/Looper.svg?branch=master

Another web framework written in Nim  

build upon [chronos](https://github.com/status-im/nim-chronos.git) and serveral excellent projects.

`Looper` will self contain manageable dependencies source code as much as posibble for accelerating development.  

`Looper` current stage is proving my idea.  

## Compile flags  

``` nim 
const HttpRequestBufferSize* {.intdefine.} = 1.Kb
const HttpHeadersLength* {.intdefine.} = int(HttpRequestBufferSize / 32) 
# 32 is sizeof MofuHeader
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
## Limitations  

the `mofuparser` use `SIMD` which relys on cpu support `SSE` or `AVX` instructions  

## License  

Apache License 2.0