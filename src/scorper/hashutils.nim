import hashes

proc toHexLowerImpl(x: BiggestUInt, len: Positive, handleNegative: bool): string {.noSideEffect.} =
  const
    HexChars = "0123456789abcdef"
  var n = x
  result = newString(len)
  for j in countdown(len-1, 0):
    result[j] = HexChars[int(n and 0xF)]
    n = n shr 4
    # handle negative overflow
    if n == 0 and handleNegative: n = not(BiggestUInt 0)

proc toHexLower*[T: SomeInteger](x: T): string {.noSideEffect.} =
  toHexLowerImpl(cast[BiggestUInt](x), 2*sizeof(T), x < 0)

proc toHexLower*[T: SomeInteger](x: T, len: Positive): string {.noSideEffect.} =
  toHexLowerImpl(cast[BiggestUInt](x), len, x < 0)

proc hashFromFile*(filepath: string): Hash =
  assert filepath.len > 0, "filepath must not be empty string"
  const bufSize = 8192
  var bin: File
  if not open(bin, filepath): return
  var buf {.noinit.}: array[bufSize, char]
  while true:
    var readBytes = bin.readChars(buf, 0, bufSize)
    result = result.`!&`(hashData(buf[0].addr, readBytes).int)
    if readBytes != bufSize: break
  close(bin)
  result = hashWangYi1(result)

when isMainModule:
  echo toHexLower hashFromFile(currentSourcePath)
