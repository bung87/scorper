#
#
#          Nimrod's x86 sse3 intrinsics
#        (c) Copyright 2014 Ben Segovia
#
#    See the file copying.txt, included in this
#    distribution, for details about the copyright.
#

const someGcc = defined(gcc) or defined(llvm_gcc) or defined(clang)
when someGcc:
  {.passC: "-msse -msse2 -msse3".}
  {.passL: "-msse -msse2 -msse3".}

import x86_mmx
import x86_sse
import x86_sse2

proc lddqu_si128*(p: ptr m128i): m128i
  {.importc: "_mm_lddqu_si128", header: "pmmintrin.h".}
  ## Exposes _mm_lddqu_si128 intrinsics

proc addsub_ps*(a: m128, b: m128): m128
  {.importc: "_mm_addsub_ps", header: "pmmintrin.h".}
  ## Exposes _mm_addsub_ps intrinsics

proc hadd_ps*(a: m128, b: m128): m128
  {.importc: "_mm_hadd_ps", header: "pmmintrin.h".}
  ## Exposes _mm_hadd_ps intrinsics

proc hsub_ps*(a: m128, b: m128): m128
  {.importc: "_mm_hsub_ps", header: "pmmintrin.h".}
  ## Exposes _mm_hsub_ps intrinsics

proc movehdup_ps*(a: m128): m128
  {.importc: "_mm_movehdup_ps", header: "pmmintrin.h".}
  ## Exposes _mm_movehdup_ps intrinsics

proc moveldup_ps*(a: m128): m128
  {.importc: "_mm_moveldup_ps", header: "pmmintrin.h".}
  ## Exposes _mm_moveldup_ps intrinsics

proc addsub_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_addsub_pd", header: "pmmintrin.h".}
  ## Exposes _mm_addsub_pd intrinsics

proc hadd_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_hadd_pd", header: "pmmintrin.h".}
  ## Exposes _mm_hadd_pd intrinsics

proc hsub_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_hsub_pd", header: "pmmintrin.h".}
  ## Exposes _mm_hsub_pd intrinsics

proc movedup_pd*(a: m128d): m128d
  {.importc: "_mm_movedup_pd", header: "pmmintrin.h".}
  ## Exposes _mm_movedup_pd intrinsics

proc monitor*(p: ptr int8, extensions: int32, hint32s: int32): void
  {.importc: "_mm_monitor", header: "pmmintrin.h".}
  ## Exposes _mm_monitor intrinsics

proc mwait*(extensions: int32, hint32s: int32): void
  {.importc: "_mm_mwait", header: "pmmintrin.h".}
  ## Exposes _mm_mwait intrinsics

# Export all pmmintrin.h constants
const DENORMALS_ZERO_ON* = 0x0040
const DENORMALS_ZERO_OFF* = 0x0000
const DENORMALS_ZERO_MASK* = 0x0040

# Export all pmmintrin.h macros
proc get_denormals_zero_mode*() : int32 {.inline.} =
  getcsr() and DENORMALS_ZERO_MASK

proc set_denormals_zero_mode*(x: int32) {.inline.} =
  setcsr((getcsr() and not DENORMALS_ZERO_MASK) or x)

# Assert we generate proper C code
when isMainModule:
  var mym128 = set1_ps(1.0)
  var mym128i = setr_epi32(1,2,3,4)
  var mym128d = set1_pd(1.0)
  var argm128 = set1_ps(1.0)
  var argm128i = setr_epi32(1,2,3,4)
  var argm128d = set1_pd(1.0)
  var argptrm128i : ptr m128i = addr(argm128i)

  mym128i = lddqu_si128(argptrm128i)
  mym128 = addsub_ps(argm128, argm128)
  mym128 = hadd_ps(argm128, argm128)
  mym128 = hsub_ps(argm128, argm128)
  mym128 = movehdup_ps(argm128)
  mym128 = moveldup_ps(argm128)
  mym128d = addsub_pd(argm128d, argm128d)
  mym128d = hadd_pd(argm128d, argm128d)
  mym128d = hsub_pd(argm128d, argm128d)
  mym128d = movedup_pd(argm128d)

