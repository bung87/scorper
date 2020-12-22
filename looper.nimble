# Package

version       = "0.1.0"
author        = "bung87"
description   = "Another web framework written in Nim"
license       = "Apache License 2.0"
srcDir        = "src"
skipDirs      = @["tests","examples"]

# Dependencies

requires "nim >= 1.2.0"
requires "https://github.com/status-im/nim-chronos.git"
requires "npeg"
requires "https://github.com/nortero-code/rx-nim"

# task test, "Runs the test suite":
  # exec "testament --megatest:off pattern 'tests/*.nim'"

task docs,"a":
  exec "nim doc --project src/looper.nim"

task ghpage,"gh page":
  cd "src/htmldocs" 
  exec "git init"
  exec "git add ."
  exec "git config user.name \"bung87\""
  exec "git config user.email \"crc32@qq.com\""
  exec "git commit -m \"docs(docs): update gh-pages\""
  let url = "\"https://bung87@github.com/bung87/looper.git\""
  exec "git push --force --quiet " & url & " master:gh-pages"

task benchmark,"benchmark":
  exec "nim c -r -d:release --threads:on -d:port=8888 benchmark/benchmark.nim"
  exec "nim c -r -d:release --threads:on -d:port=9999 -d:demoPath=benchmark/tjester.nim benchmark/benchmark.nim"
