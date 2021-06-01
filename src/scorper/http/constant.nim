import netunit

const HttpRequestBufferSize {.intdefine.} = 2.Kb
const BufferLimitExceeded = "Buffer Limit Exceeded"
const ContentLengthMismatch = "Content-Length does not match actual"
const HttpHeadersLength {.intdefine.} = int(HttpRequestBufferSize / 32) # 32 is sizeof MofuHeader
const gzipMinLength {.intdefine.} = 20 # same as nginx config http://nginx.org/en/docs/http/ngx_http_gzip_module.html#gzip_min_length
const HttpServer {.strdefine.} = "scorper"
const GzipEnable {.booldefine.} = true
const TimeOut {.intdefine.} = 300
