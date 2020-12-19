import ./looper/http/acceptparser
import sequtils
block basic:
  let parser = accpetParser()
  var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
  let accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
  let r = parser.match(accept, mimes)
  doAssert mimes.mapIt( (mime: it.mime, q: it.q)) == @[(mime: "text/html", q: 1.0), (mime: "application/xhtml+xml",
      q: 1.0), (mime: "application/xml", q: 0.9), (mime: "*/*", q: 0.8)]

block defaultQuality:
  let parser = accpetParser()
  let accept = "application/json;q=0.2, text/html"
  var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
  let r = parser.match(accept, mimes)
  doAssert mimes.mapIt( (mime: it.mime, q: it.q)) == @[(mime: "text/html", q: 1.0), (mime: "application/json", q: 0.2)]

block order:
  let parser = accpetParser()
  let accept = "application/json;q=0.6, text/plain;q=0.8"
  var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
  var r = parser.match(accept, mimes)
  doAssert mimes.mapIt( (mime: it.mime, q: it.q)) == @[(mime: "text/plain", q: 0.8), (mime: "application/json", q: 0.6)]

block customParams:
  let parser = accpetParser()
  let accept = "text/*, text/plain;format=flowed, text/plain, text/plain;level=1, text/html, text/plain;level=2, */*, image/*, text/rich"
  var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
  var r = parser.match(accept, mimes)

block disallows:
  let parser = accpetParser()
  let accept = "text/plain, application/json;q=0.5, text/html, text/drop;q=0"
  var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
  var r = parser.match(accept, mimes)
  doAssert mimes.mapIt(it.mime) == @["text/plain", "text/html", "application/json"]

block `the most specific reference has precedence`:
  let parser = accpetParser()
  let accept = "text/*, text/plain, text/plain;format=flowed, */*"
  var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
  var r = parser.match(accept, mimes)
  doAssert mimes.mapIt( (mime: it.mime, q: it.q, extro: it.extro)) == @[
    (mime: "text/plain", q: 1.0, extro: 1),
    (mime: "text/plain", q: 1.0, extro: 0),
    (mime: "text/*", q: 1.0, extro: 0),
    (mime: "*/*", q: 1.0, extro: 0)]

block q:
  let parser = accpetParser()
  let accept = "text/*, text/plain;format=flowed, text/plain, text/plain;level=1, text/html, text/plain;level=2, */*, image/*, text/rich"
  var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
  var r = parser.match(accept, mimes)
  # TODO not sure this order is correct
  echo mimes
  # doAssert mimes.mapIt(it.q) == @[1.0, 0.7, 0.3, 0.5, 0.4 ]
