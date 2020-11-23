# Package

version       = "0.1.0"
author        = "bung87"
description   = "Another web framework written in Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.5.1"
requires "https://github.com/status-im/nim-chronos.git"

task test, "Runs the test suite":
  exec "testament --megatest:off pattern 'tests/*.nim'"