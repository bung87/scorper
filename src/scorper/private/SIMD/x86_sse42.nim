#
#
#          Nimrod's x86 sse42 intrinsics
#        (c) Copyright 2014 Ben Segovia
#
#    See the file copying.txt, included in this
#    distribution, for details about the copyright.
#

const someGcc = defined(gcc) or defined(llvm_gcc) or defined(clang)
when someGcc:
  {.passC: "-msse -msse2 -msse3 -mssse3 -msse4".}
  {.passL: "-msse -msse2 -msse3 -mssse3 -msse4".}

import x86_mmx
import x86_sse
import x86_sse2
import x86_sse3
import x86_ssse3
import x86_sse41

proc cmpgt_epi64*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_cmpgt_epi64", header: "nmmintrin.h".}
  ## Exposes _mm_cmpgt_epi64 intrinsics

proc crc32_u8*(C: int32, D: int8): int32
  {.importc: "_mm_crc32_u8", header: "nmmintrin.h".}
  ## Exposes _mm_crc32_u8 intrinsics

proc crc32_u16*(C: int32, D: int16): int32
  {.importc: "_mm_crc32_u16", header: "nmmintrin.h".}
  ## Exposes _mm_crc32_u16 intrinsics

proc crc32_u32*(C: int32, D: int32): int32
  {.importc: "_mm_crc32_u32", header: "nmmintrin.h".}
  ## Exposes _mm_crc32_u32 intrinsics

proc cmpistrm*(a: m128i, b: m128i, c: int32): m128i
  {.importc: "_mm_cmpistrm", header: "nmmintrin.h".}
  ## Exposes _mm_cmpistrm intrinsics

proc cmpistri*(a: m128i, b: m128i, c: int32): int32
  {.importc: "_mm_cmpistri", header: "nmmintrin.h".}
  ## Exposes _mm_cmpistri intrinsics

proc cmpistra*(a: m128i, b: m128i, c: int32): int32
  {.importc: "_mm_cmpistra", header: "nmmintrin.h".}
  ## Exposes _mm_cmpistra intrinsics

proc cmpistrc*(a: m128i, b: m128i, c: int32): int32
  {.importc: "_mm_cmpistrc", header: "nmmintrin.h".}
  ## Exposes _mm_cmpistrc intrinsics

proc cmpistro*(a: m128i, b: m128i, c: int32): int32
  {.importc: "_mm_cmpistro", header: "nmmintrin.h".}
  ## Exposes _mm_cmpistro intrinsics

proc cmpistrs*(a: m128i, b: m128i, c: int32): int32
  {.importc: "_mm_cmpistrs", header: "nmmintrin.h".}
  ## Exposes _mm_cmpistrs intrinsics

proc cmpistrz*(a: m128i, b: m128i, c: int32): int32
  {.importc: "_mm_cmpistrz", header: "nmmintrin.h".}
  ## Exposes _mm_cmpistrz intrinsics

proc cmpestrm*(a: m128i, la: int32, b: m128i, lb: int32, mode: int32): m128i
  {.importc: "_mm_cmpestrm", header: "nmmintrin.h".}
  ## Exposes _mm_cmpestrm intrinsics

proc cmpestri*(a: m128i, la: int32, b: m128i, lb: int32, mode: int32): int32
  {.importc: "_mm_cmpestri", header: "nmmintrin.h".}
  ## Exposes _mm_cmpestri intrinsics

proc cmpestra*(a: m128i, la: int32, b: m128i, lb: int32, mode: int32): int32
  {.importc: "_mm_cmpestra", header: "nmmintrin.h".}
  ## Exposes _mm_cmpestra intrinsics

proc cmpestrc*(a: m128i, la: int32, b: m128i, lb: int32, mode: int32): int32
  {.importc: "_mm_cmpestrc", header: "nmmintrin.h".}
  ## Exposes _mm_cmpestrc intrinsics

proc cmpestro*(a: m128i, la: int32, b: m128i, lb: int32, mode: int32): int32
  {.importc: "_mm_cmpestro", header: "nmmintrin.h".}
  ## Exposes _mm_cmpestro intrinsics

proc cmpestrs*(a: m128i, la: int32, b: m128i, lb: int32, mode: int32): int32
  {.importc: "_mm_cmpestrs", header: "nmmintrin.h".}
  ## Exposes _mm_cmpestrs intrinsics

proc cmpestrz*(a: m128i, la: int32, b: m128i, lb: int32, mode: int32): int32
  {.importc: "_mm_cmpestrz", header: "nmmintrin.h".}
  ## Exposes _mm_cmpestrz intrinsics

# Export all nmmintrin.h constants
const SIDD_UBYTE_OPS* = 0x00
const SIDD_UWORD_OPS* = 0x01
const SIDD_SBYTE_OPS* = 0x02
const SIDD_SWORD_OPS* = 0x03
const SIDD_CMP_EQUAL_ANY* = 0x00
const SIDD_CMP_RANGES* = 0x04
const SIDD_CMP_EQUAL_EACH* = 0x08
const SIDD_CMP_EQUAL_ORDERED* = 0x0c
const SIDD_POSITIVE_POLARITY* = 0x00
const SIDD_NEGATIVE_POLARITY* = 0x10
const SIDD_MASKED_POSITIVE_POLARITY* = 0x20
const SIDD_MASKED_NEGATIVE_POLARITY* = 0x30
const SIDD_LEAST_SIGNIFICANT* = 0x00
const SIDD_MOST_SIGNIFICANT* = 0x40
const SIDD_BIT_MASK* = 0x00
const SIDD_UNIT_MASK* = 0x40

# Assert we generate proper C code
when isMainModule:
  var myint32 : int32 = 2
  var mym128i = setr_epi32(1,2,3,4)
  var argint8 : int8 = 1
  var argint16 : int16 = 1
  var argm128i = setr_epi32(1,2,3,4)
  mym128i = cmpgt_epi64(argm128i, argm128i)
  myint32 = crc32_u8(1, argint8)
  myint32 = crc32_u16(1, argint16)
  myint32 = crc32_u32(1, 1)
  mym128i = cmpistrm(argm128i, argm128i, 1)
  myint32 = cmpistri(argm128i, argm128i, 1)
  myint32 = cmpistra(argm128i, argm128i, 1)
  myint32 = cmpistrc(argm128i, argm128i, 1)
  myint32 = cmpistro(argm128i, argm128i, 1)
  myint32 = cmpistrs(argm128i, argm128i, 1)
  myint32 = cmpistrz(argm128i, argm128i, 1)
  mym128i = cmpestrm(argm128i, 1, argm128i, 1, 1)
  myint32 = cmpestri(argm128i, 1, argm128i, 1, 1)
  myint32 = cmpestra(argm128i, 1, argm128i, 1, 1)
  myint32 = cmpestrc(argm128i, 1, argm128i, 1, 1)
  myint32 = cmpestro(argm128i, 1, argm128i, 1, 1)
  myint32 = cmpestrs(argm128i, 1, argm128i, 1, 1)
  myint32 = cmpestrz(argm128i, 1, argm128i, 1, 1)

