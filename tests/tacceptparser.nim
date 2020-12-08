import ./looper/http/acceptparser

block basic:
  let parser = accpetParser()
  var mimes = newSeq[tuple[mime:string,q:float]]()
  let accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
  let r = parser.match(accept,mimes)
  doAssert mimes == @[(mime: "text/html", q: 1.0), (mime: "application/xhtml+xml", q: 1.0), (mime: "application/xml", q: 0.9), (mime: "*/*", q: 0.8)]

block defaultQuality:
  let parser = accpetParser()
  let accept = "application/json;q=0.2, text/html"
  var mimes = newSeq[tuple[mime:string,q:float]]()
  let r = parser.match(accept,mimes)
  doAssert mimes == @[(mime: "text/html", q: 1.0), (mime: "application/json", q: 0.2)]

block order:
  let parser = accpetParser()
  let accept = "application/json;q=0.6, text/plain;q=0.8"
  var mimes = newSeq[tuple[mime:string,q:float]]()
  var r = parser.match(accept,mimes)
  doAssert mimes == @[(mime: "text/plain", q: 0.8), (mime: "application/json", q: 0.6)]

block customParams:
  let parser = accpetParser()
  let accept = "text/*, text/plain;format=flowed, text/plain, text/plain;level=1, text/html, text/plain;level=2, */*, image/*, text/rich"
  var mimes = newSeq[tuple[mime:string,q:float]]()
  var r = parser.match(accept,mimes)
  echo mimes

block disallows:
  let parser = accpetParser()
  let accept = "text/plain, application/json;q=0.5, text/html, text/drop;q=0"
  var mimes = newSeq[tuple[mime:string,q:float]]()
  var r = parser.match(accept,mimes)
  doAssert mimes == @[(mime: "text/plain", q: 1.0), (mime: "text/html", q: 1.0), (mime: "application/json", q: 0.5)]

block mixed:
  let parser = accpetParser()
  let accept = "text/*, text/plain;format=flowed, text/plain, text/plain;level=1, text/html, text/plain;level=2, */*, image/*, text/rich"
  var mimes = newSeq[tuple[mime:string,q:float]]()
  var r = parser.match(accept,mimes)
  echo mimes
  #           'text/html',
  #           'text/plain;format=flowed',
  #           'text/plain;level=1',
  #           'text/plain;level=2',
  #           'text/plain',
  #           'text/rich',
  #           'text/*',
  #           '*/*'
