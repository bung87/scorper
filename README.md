# looper  

Another web framework written in Nim  

build upon [chronos](https://github.com/status-im/nim-chronos.git) and serveral excellent projects.

`looper` will self contain manageable dependencies source code as much as posibble for accelerating development.  

`looper` current stage is proving my idea.  

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
- [x] Http Basic auth.  
- [x] Serve static files (env:StaticDir)  
- [x] Parse JSON lazyly.  
- [x] cookies module.  
- [ ] Parse JSON streamingly.  
- [ ] Better error control flow.  

## License  

Apache License 2.0