import math

{.push used,hint[Name]: off.}

proc Kb*(n: Positive): Positive {.compileTime.} = Positive(n * 1024)
proc Mb*(n: Positive): Positive {.compileTime.} = Positive(n * 1024 ^ 2)
proc Gb*(n: Positive): Positive {.compileTime.} = Positive(n * 1024 ^ 3)

{.pop.}