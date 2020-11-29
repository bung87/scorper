include ./looper/http/urlencodedparser
import ./looper/http/constant
import unittest

test "multi":
  var r = newSeq[tuple[key, value: TaintedString]]()
  var buffer:array[HttpRequestBufferSize,char]
  var s = "a=b&c=d\c\l"
  copyMem(buffer[0].addr,s[0].addr,s.len)
  var parser = new UrlEncodedParser
  parser.src = buffer.addr
  parser.buf = buffer[0].addr
  parser.state = nameBegin
  parser.processChar(r)
  check r == @[(key: "a", value: "b"), (key: "c", value: "d")]
test "empty":
  var r = newSeq[tuple[key, value: TaintedString]]()
  var buffer:array[HttpRequestBufferSize,char]
  var s = "a=&c=d\c\l"
  copyMem(buffer[0].addr,s[0].addr,s.len)
  var parser = new UrlEncodedParser
  parser.src = buffer.addr
  parser.buf = buffer[0].addr
  parser.state = nameBegin
  parser.processChar(r)
  check r == @[(key: "a", value: ""), (key: "c", value: "d")]
test "empty2":
  var r = newSeq[tuple[key, value: TaintedString]]()
  var buffer:array[HttpRequestBufferSize,char]
  var s = "a=b&c=\c\l"
  copyMem(buffer[0].addr,s[0].addr,s.len)
  var parser = new UrlEncodedParser
  parser.src = buffer.addr
  parser.buf = buffer[0].addr
  parser.state = nameBegin
  parser.processChar(r)
  check r == @[(key: "a", value: "b"), (key: "c", value: "")]