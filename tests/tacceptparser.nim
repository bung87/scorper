import ./looper/http/acceptparser

var parser = new AccpetParser

block basic:
  let accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
  let r = parser.parse(accept)
  echo r
  doAssert r == @[(items: @["text/html", "application/xhtml+xml", "application/xml"], quality: 0.9), (items: @["*/*"], quality: 0.8)]

block defaultQuality:
  let accept = "application/json;q=0.2, text/html"
  let r = parser.parse(accept)
  echo r

block order:
  let accept = "application/json;q=0.6, text/plain;q=0.8"
  var r = parser.parse(accept)
  echo r
  doAssert r == @[(items: @["text/plain"], quality: 0.8), (items: @["application/json"], quality: 0.6)]

block customParams:
  let accept = "text/*, text/plain;format=flowed, text/plain, text/plain;level=1, text/html, text/plain;level=2, */*, image/*, text/rich"
  var r = parser.parse(accept)
  echo r

block disallows:
  let accept = "text/plain, application/json;q=0.5, text/html, text/drop;q=0"
  var r = parser.parse(accept)
  echo r

block mixed:
  let accept = "text/*, text/plain;format=flowed, text/plain, text/plain;level=1, text/html, text/plain;level=2, */*, image/*, text/rich"
  var r = parser.parse(accept)
  echo r
  #           'text/html',
  #           'text/plain;format=flowed',
  #           'text/plain;level=1',
  #           'text/plain;level=2',
  #           'text/plain',
  #           'text/rich',
  #           'text/*',
  #           '*/*'