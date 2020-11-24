import parseutils, strutils

proc parseBoundary*(line: string): tuple[i:int,boundary:string] = 
  # retrieve boundary from Content-Type
  const Flag = "multipart/form-data;"
  const FlagLen = Flag.len
  result.i = line.find(Flag)
  if result.i > -1:
    if line.find('"',result.i ) == -1:
      let j = line.find('=',result.i )
      if j != -1:
        result.boundary = line[j + 1 ..< line.len]
    else:
      result.boundary = captureBetween(line,'"','"',result.i + FlagLen)

when isMainModule:
  let a =  parseBoundary("""multipart/form-data; boundary="---- next message ----"""")
  doAssert a.i != -1 and a.boundary.len > 0
  let b = parseBoundary("""multipart/form-data;boundary=---- next message ----""")
  doAssert b.i != -1 and b.boundary.len > 0