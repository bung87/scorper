import netunit

const HttpRequestBufferSize* {.intdefine.} = 1.Kb
const BufferLimitExceeded* = "Buffer Limit Exceeded" 
const ContentLengthMismatch* = "Content-Length does not match actual"