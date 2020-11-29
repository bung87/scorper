import ../hashutils
import os,times,hashes

proc etagFromFile*(filepath: string, isWeak = true): string =
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag
  if isWeak:
    let info = getFileInfo(filepath)
    let ns = info.lastWriteTime.toUnix().uint64 * 1e9.uint64 + info.lastWriteTime.nanosecond.uint64
    let size = toHexLower( info.size, sizeof(uint64))
    result = "W/" & '"' & size & '-' & toHexLower( ns, sizeof(uint64)) & '"' 
  else:
    result = '"' & toHexLower(hashFromFile(filepath)) & '"' 

when isMainModule:
  import ./httpcore
  var test = newHttpHeaders()
  test["ETag"] = etagFromFile(currentSourcePath)
  echo generateHeaders(test)
  var test2 = newHttpHeaders()
  test2["ETag"] = etagFromFile(currentSourcePath,false)
  echo generateHeaders(test2)