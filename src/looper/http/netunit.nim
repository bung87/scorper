import math

proc Mb*(n: Positive):Positive {.compileTime.} = Positive(8 * pow(1024.0, 2))