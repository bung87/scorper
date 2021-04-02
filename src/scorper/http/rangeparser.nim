import npeg, strutils #, sequtils, math, algorithm
import npeg/codegen
export npeg

# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Range

proc rangeParser*(): Parser[char, seq[tuple[starts: int, ends: int]]] =
  result = peg("pairs", d: seq[tuple[starts: int, ends: int]]):
    pairs <- "bytes=" * pair * *(',' * * Blank * pair) * eof
    pair <- >*Digit * "-" * ?>(*Digit):
      let starts = if len($1) > 0: parseInt($1) else: 0
      let ends = if len($1) == 0: parseInt("-" & $2) else: (if len($2) > 0: parseInt($2) else: 0)
      d.add((starts, ends))
    eof <- !1:
      discard

when isMainModule:
  let parser = rangeParser()
  var ranges = newSeq[tuple[starts: int, ends: int]]()
  let t1 = "bytes=0-1023"
  let r = parser.match(t1, ranges)
  doAssert ranges == @[(starts: 0, ends: 1023)]
  ranges.setLen(0)
  let t2 = "bytes=0-50, 100-150"
  let r2 = parser.match(t2, ranges)
  doAssert ranges == @[(starts: 0, ends: 50), (starts: 100, ends: 150)]
  ranges.setLen(0)
  let t3 = "bytes=200-1000, 2000-6576, 19000-"
  let r3 = parser.match(t3, ranges)
  doAssert ranges == @[(starts: 200, ends: 1000), (starts: 2000, ends: 6576), (starts: 19000, ends: 0)]
  ranges.setLen(0)
  let t4 = "bytes=0-499, -500"
  let r4 = parser.match(t4, ranges)
  doAssert ranges == @[(starts: 0, ends: 499), (starts: 0, ends: -500)]
  var contentLength = 0
  for b in ranges:
    if b[1] > 0:
      contentLength = contentLength + b[1] - b[0] + 1
    else:
      contentLength = contentLength + abs(b[1])
  doAssert contentLength == 1000

