# port of https://github.com/mscdex/streamsearch/blob/2df4e8db15b379f6faf0196a4ea3868bd3046e32/lib/sbmh.js

import std/[algorithm]

type StreamSearcherCallback = proc (isMatch: bool; data: openArray[char];
                                start: int; e: int; isSafeData: bool) {.raises: [CatchableError].}
type StreamSearcher* = ref object
  lookbehind: array[70, char]
  needle: string
  bufPos: int
  lookbehindSize: int
  matches: int
  maxMatches: int
  badCharTbl: array[256, uint8]
  cb: StreamSearcherCallback

proc getPos*(self: StreamSearcher;):int =
  return self.bufPos

proc memcmp(buf1: openArray[char]; pos1: int; buf2: openArray[char]; pos2: int;
    num: int): bool =
  for i in 0 ..< num:
    if buf1[pos1 + i] != buf2[pos2 + i]:
      return false
  return true

proc matchNeedle(self: StreamSearcher; data: openArray[char]; iPos: int;
    len: int): bool =
  let lbSize = self.lookbehindSize
  let needle = self.needle
  var pos = iPos
  for i in 0 ..< len:
    let ch = if pos < 0: self.lookbehind[lbSize + pos] else: data[pos]
    if ch != needle[i]:
      return false
    inc pos
  return true

proc newStreamSearcher*(): StreamSearcher =
  new result

proc init*(self: StreamSearcher; needle: string; cb: StreamSearcherCallback; maxMatches = int.high) =
  self.needle = needle
  self.maxMatches = maxMatches
  self.cb = cb
  let needleLen = needle.len
  doAssert needleLen > 1 and needleLen <= uint8.high.int
  self.badCharTbl.fill(needleLen.uint8)
  for i in 0 ..< needleLen - 1:
    self.badCharTbl[needle[i].int] = uint8(needleLen - 1 - i)

proc reset*(self: StreamSearcher; needle: string; ) =
  self.matches = 0
  self.lookbehindSize = 0
  self.bufPos = 0
  let needleLen = needle.len
  doAssert needleLen > 1 and needleLen <= uint8.high.int
  self.badCharTbl.fill(needleLen.uint8)
  for i in 0 ..< needleLen - 1:
    self.badCharTbl[needle[i].int] = uint8(needleLen - 1 - i)

proc resetNums*(self: StreamSearcher) =
  self.matches = 0
  self.lookbehindSize = 0
  self.bufPos = 0

proc destroy*(self: StreamSearcher) =
  let lbSize = self.lookbehindSize
  if lbSize > 0:
    self.cb(false, self.lookbehind, 0, lbSize, false)
  self.matches = 0
  self.lookbehindSize = 0
  self.bufPos = 0

proc feed*(self: StreamSearcher; data: openArray[char]; ): int {.raises: [CatchableError].} =
  let len = data.len
  let needle = self.needle
  let needleLen = needle.len

  # Positive: points to a position in `data`
  #           pos == 3 points to data[3]
  # Negative: points to a position in the lookbehind buffer
  #           pos == -2 points to lookbehind[lookbehindSize - 2]
  var pos = -self.lookbehindSize
  let lastNeedleCharPos = needleLen - 1
  let lastNeedleChar = needle[lastNeedleCharPos]
  let iEnd = len - needleLen

  if pos < 0:
    # Lookbehind buffer is not empty. Perform Boyer-Moore-Horspool
    # search with character lookup code that considers both the
    # lookbehind buffer and the current round's haystack data.
    #
    # Loop until
    #   there is a match.
    # or until
    #   we've moved past the position that requires the
    #   lookbehind buffer. In this case we switch to the
    #   optimized loop.
    # or until
    #   the character to look at lies outside the haystack.
    while (pos < 0 and pos <= iEnd):
      let nextPos = pos + lastNeedleCharPos
      let ch = if nextPos < 0: self.lookbehind[self.lookbehindSize +
          nextPos] else: data[nextPos]
      if ch == lastNeedleChar and self.matchNeedle(data, pos,
          lastNeedleCharPos):
        self.lookbehindSize = 0
        inc self.matches
        if (pos > -self.lookbehindSize):
          self.cb(true, self.lookbehind, 0, self.lookbehindSize + pos, false)
        else:
          self.cb(true, [], 0, 0, true)
        self.bufPos = pos + needleLen
        return self.bufPos
      pos.inc self.badCharTbl[ch.int].int

    # No match.

    # There's too few data for Boyer-Moore-Horspool to run,
    # so let's use a different algorithm to skip as much as
    # we can.
    # Forward pos until
    #   the trailing part of lookbehind + data
    #   looks like the beginning of the needle
    # or until
    #   pos == 0
    while pos < 0 and matchNeedle(self, data, pos, len - pos) == false:
      inc pos
    if pos < 0:
      # Cut off part of the lookbehind buffer that has
      # been processed and append the entire haystack
      # into it.
      let bytesToCutOff = self.lookbehindSize + pos
      if bytesToCutOff > 0:
        # The cut off data is guaranteed not to contain the needle.
        self.cb(false, self.lookbehind, 0, bytesToCutOff, false)

      self.lookbehindSize.dec bytesToCutOff
      copyMem(self.lookbehind[0].addr, self.lookbehind[bytesToCutOff].addr,
          self.lookbehindSize - bytesToCutOff)
      copyMem(self.lookbehind[self.lookbehindSize].addr, data[0].unsafeAddr, data.len)
      self.lookbehindSize += len

      self.bufPos = len
      return len
    # Discard lookbehind buffer.
    self.cb(false, self.lookbehind, 0, self.lookbehindSize, false)
    self.lookbehindSize = 0

  pos += self.bufPos
  let firstNeedleChar = needle[0]

  # Lookbehind buffer is now empty. Perform Boyer-Moore-Horspool
  # search with optimized character lookup code that only considers
  # the current round's haystack data.
  while (pos <= iEnd):
    let ch = data[pos + lastNeedleCharPos]

    if ch == lastNeedleChar and data[pos] == firstNeedleChar and memcmp(needle,
        0, data, pos, lastNeedleCharPos):
      inc self.matches
      if pos > 0:
        self.cb(true, data, self.bufPos, pos, true)
      else:
        self.cb(true, [], 0, 0, true)
      self.bufPos = pos + needleLen
      return self.bufPos

    pos.inc self.badCharTbl[ch.int].int

  # There was no match. If there's trailing haystack data that we cannot
  # match yet using the Boyer-Moore-Horspool algorithm (because the trailing
  # data is less than the needle size) then match using a modified
  # algorithm that starts matching from the beginning instead of the end.
  # Whatever trailing data is left after running this algorithm is added to
  # the lookbehind buffer.
  while (pos < len):
    if data[pos] != firstNeedleChar or memcmp(data, pos, needle, 0, len -
        pos) == false:
      inc pos
      continue
    copyMem(self.lookbehind[0].addr, data[pos].unsafeAddr, len - pos)
    self.lookbehindSize = len - pos
    break

  # Everything until `pos` is guaranteed not to contain needle data.
  if pos > 0:
    self.cb(false, data, self.bufPos, if pos < len: pos else: len, true)

  self.bufPos = len
  return len

proc push*(self: StreamSearcher; chunk: openArray[char]; pos: int = 0): int {.raises: [CatchableError].} =
  let chunkLen = chunk.len
  self.bufPos = pos
  while (result != chunkLen and self.matches < self.maxMatches):
    result = self.feed(chunk)
  return result

when isMainModule:
  let needle = "\r\n"
  let cb = proc (isMatch: bool; data: openArray[char]; start: int; e: int;
      isSafeData: bool) =
    if data.len > 0:
      var s = data[start ..< e]
      echo "data: ", s
    if isMatch:
      echo "match!"

  let ss = newStreamSearcher()
  ss.init(needle,cb)
  let chunks = @[
    "foo",
    " bar",
    "\r",
    "\n",
    "baz, hello\r",
    "\n world.",
    "\r\n Node.JS rules!!\r\n\r\n",
  ]
  for chunk in chunks:
    discard ss.push(chunk)

