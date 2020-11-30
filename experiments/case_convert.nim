import strutils, times
# https://tools.ietf.org/html/rfc7230#section-3.2.6
# field-name = token

# token = 1*tchar

# tchar = "!" / "#" / "$" / "%" / "&" / "'" / "*" / "+" / "-" /
#         "." / "^" / "_" / "`" / "|" / "~" / DIGIT / ALPHA

# between Z and a
# 91	133	5B	01011011	[	&#91;	Opening bracket
# 92	134	5C	01011100	\	&#92;	Backslash
# 93	135	5D	01011101	]	&#93;	Closing bracket
# 94	136	5E	01011110	^	&#94;	Caret - circumflex
# 95	137	5F	01011111	_	&#95;	Underscore
# 96	140	60	01100000	`	&#96;	Grave accent

# A .. z 65 .. 122,  65 .. 90, 97 .. 122
# 1 .. 9 = 49 .. 57
# - 45
# _ 95
echo cast[uint8]('1')
var a = '1'
let b = cast[char](cast[uint8](a) xor 0b0010_0000'u8)
echo repr b

block toupper:
  var h: char
  for c in 'a' .. 'z':
    h = cast[char](cast[uint8](c) xor 0b0010_0000'u8)
    doAssert h == c.toUpperAscii

block tolower:
  var h: char
  for c in 'A' .. 'Z':
    h = cast[char](cast[uint8](c) xor 0b0010_0000'u8)
    doAssert h == c.toLowerAscii

var t0 = cpuTime()
var d: char
for i in 1 .. 100_000:
  for c in 'A' .. 'Z':
    d = cast[char](cast[uint8](c) xor 0b0010_0000'u8)
var r1 = cpuTime() - t0
echo "CPU time xor ", r1

var t1 = cpuTime()
var e: char
for i in 1 .. 100_000:
  for c in 'A' .. 'Z':
    e = toLowerAscii(c)
var r2 = cpuTime() - t1
echo "CPU time toLowerAscii ", r2
doAssert r1 < r2
echo $(r1 / r2 * 100) & "%"

const All = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&\'()*+,-./:;?@[\\]^_`{|}~ \t\n\r\x0b\x0c"

const AllAllowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!#$%&\'*+-./^_`|~" & "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

block strtoLowerAscii:
  var t3 = cpuTime()
  var e: char
  for i in 1 .. 100_000:
    for c in AllAllowed:
      e = toLowerAscii(c)
  var t4 = cpuTime() - t3
  echo "CPU time string toLowerAscii ", t4

block strxor:
  var t3 = cpuTime()
  var e: char
  for i in 1 .. 100_000:
    for c in AllAllowed:
      if likely c.isAlphaAscii:
        e = cast[char](cast[uint8](c) xor 0b0010_0000'u8)
      else:
        e = c
  var t4 = cpuTime() - t3
  echo "CPU time string strxor ", t4
# just use toLowerAscii unless sure about input is all alpha