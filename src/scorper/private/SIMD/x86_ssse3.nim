#
#
#          Nimrod's x86 ssee3 intrinsics
#        (c) Copyright 2014 Ben Segovia
#
#    See the file copying.txt, included in this
#    distribution, for details about the copyright.
#

const someGcc = defined(gcc) or defined(llvm_gcc) or defined(clang)
when someGcc:
  {.passC: "-msse -msse2 -msse3 -mssse3".}
  {.passL: "-msse -msse2 -msse3 -mssse3".}

# MSVC does not support MMX on 64 bits target
const vcc64Bits = defined(vcc) and defined(x86_64)

import x86_mmx
import x86_sse
import x86_sse2
import x86_sse3

when not vcc64Bits:
  proc abs_pi8*(a: m64): m64
    {.importc: "_mm_abs_pi8", header: "tmmintrin.h".}
    ## Exposes _mm_abs_pi8 intrinsics

  proc abs_pi16*(a: m64): m64
    {.importc: "_mm_abs_pi16", header: "tmmintrin.h".}
    ## Exposes _mm_abs_pi16 intrinsics

  proc abs_pi32*(a: m64): m64
    {.importc: "_mm_abs_pi32", header: "tmmintrin.h".}
    ## Exposes _mm_abs_pi32 intrinsics

  proc hsub_pi16*(a: m64, b: m64): m64
    {.importc: "_mm_hsub_pi16", header: "tmmintrin.h".}
    ## Exposes _mm_hsub_pi16 intrinsics

  proc hsub_pi32*(a: m64, b: m64): m64
    {.importc: "_mm_hsub_pi32", header: "tmmintrin.h".}
    ## Exposes _mm_hsub_pi32 intrinsics

  proc hsubs_pi16*(a: m64, b: m64): m64
    {.importc: "_mm_hsubs_pi16", header: "tmmintrin.h".}
    ## Exposes _mm_hsubs_pi16 intrinsics

  proc maddubs_pi16*(a: m64, b: m64): m64
    {.importc: "_mm_maddubs_pi16", header: "tmmintrin.h".}
    ## Exposes _mm_maddubs_pi16 intrinsics

  proc mulhrs_pi16*(a: m64, b: m64): m64
    {.importc: "_mm_mulhrs_pi16", header: "tmmintrin.h".}
    ## Exposes _mm_mulhrs_pi16 intrinsics

  proc shuffle_pi8*(a: m64, b: m64): m64
    {.importc: "_mm_shuffle_pi8", header: "tmmintrin.h".}
    ## Exposes _mm_shuffle_pi8 intrinsics

  proc sign_pi8*(a: m64, b: m64): m64
    {.importc: "_mm_sign_pi8", header: "tmmintrin.h".}
    ## Exposes _mm_sign_pi8 intrinsics

  proc sign_pi16*(a: m64, b: m64): m64
    {.importc: "_mm_sign_pi16", header: "tmmintrin.h".}
    ## Exposes _mm_sign_pi16 intrinsics

  proc sign_pi32*(a: m64, b: m64): m64
    {.importc: "_mm_sign_pi32", header: "tmmintrin.h".}
    ## Exposes _mm_sign_pi32 intrinsics

  proc alignr_pi8*(a: m64, b: m64, c: int32): m64
    {.importc: "_mm_alignr_pi8", header: "tmmintrin.h".}
    ## Exposes _mm_alignr_pi8 intrinsics

  proc hadd_pi16*(a: m64, b: m64): m64
    {.importc: "_mm_hadd_pi16", header: "tmmintrin.h".}
    ## Exposes _mm_hadd_pi16 intrinsics

  proc hadd_pi32*(a: m64, b: m64): m64
    {.importc: "_mm_hadd_pi32", header: "tmmintrin.h".}
    ## Exposes _mm_hadd_pi32 intrinsics

  proc hadds_pi16*(a: m64, b: m64): m64
    {.importc: "_mm_hadds_pi16", header: "tmmintrin.h".}
    ## Exposes _mm_hadds_pi16 intrinsics

proc abs_epi8*(a: m128i): m128i
  {.importc: "_mm_abs_epi8", header: "tmmintrin.h".}
  ## Exposes _mm_abs_epi8 intrinsics

proc abs_epi16*(a: m128i): m128i
  {.importc: "_mm_abs_epi16", header: "tmmintrin.h".}
  ## Exposes _mm_abs_epi16 intrinsics

proc abs_epi32*(a: m128i): m128i
  {.importc: "_mm_abs_epi32", header: "tmmintrin.h".}
  ## Exposes _mm_abs_epi32 intrinsics

proc hadd_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_hadd_epi16", header: "tmmintrin.h".}
  ## Exposes _mm_hadd_epi16 intrinsics

proc hadd_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_hadd_epi32", header: "tmmintrin.h".}
  ## Exposes _mm_hadd_epi32 intrinsics

proc hadds_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_hadds_epi16", header: "tmmintrin.h".}
  ## Exposes _mm_hadds_epi16 intrinsics

proc hsub_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_hsub_epi16", header: "tmmintrin.h".}
  ## Exposes _mm_hsub_epi16 intrinsics

proc hsub_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_hsub_epi32", header: "tmmintrin.h".}
  ## Exposes _mm_hsub_epi32 intrinsics

proc hsubs_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_hsubs_epi16", header: "tmmintrin.h".}
  ## Exposes _mm_hsubs_epi16 intrinsics

proc maddubs_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_maddubs_epi16", header: "tmmintrin.h".}
  ## Exposes _mm_maddubs_epi16 intrinsics

proc mulhrs_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_mulhrs_epi16", header: "tmmintrin.h".}
  ## Exposes _mm_mulhrs_epi16 intrinsics

proc sign_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_sign_epi8", header: "tmmintrin.h".}
  ## Exposes _mm_sign_epi8 intrinsics

proc sign_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_sign_epi16", header: "tmmintrin.h".}
  ## Exposes _mm_sign_epi16 intrinsics

proc sign_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_sign_epi32", header: "tmmintrin.h".}
  ## Exposes _mm_sign_epi32 intrinsics

proc alignr_epi8*(a: m128i, b: m128i, c: int32): m128i
  {.importc: "_mm_alignr_epi8", header: "tmmintrin.h".}
  ## Exposes _mm_alignr_epi8 intrinsics

proc shuffle_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_shuffle_epi8", header: "tmmintrin.h".}
  ## Exposes _mm_shuffle_epi8 intrinsics

# Assert we generate proper C code
when isMainModule:
  var mym128i = setr_epi32(1,2,3,4)
  var argm128i = setr_epi32(1,2,3,4)
  when not vcc64Bits:
    var mym64 = set1_pi32(1)
    var argm64 = set1_pi32(1)
    mym64 = abs_pi8(argm64)
    mym64 = abs_pi16(argm64)
    mym64 = abs_pi32(argm64)
    mym64 = hadd_pi16(argm64, argm64)
    mym64 = hadd_pi32(argm64, argm64)
    mym64 = hadds_pi16(argm64, argm64)
    mym64 = hsub_pi16(argm64, argm64)
    mym64 = hsub_pi32(argm64, argm64)
    mym64 = hsubs_pi16(argm64, argm64)
    mym64 = maddubs_pi16(argm64, argm64)
    mym64 = mulhrs_pi16(argm64, argm64)
    mym64 = shuffle_pi8(argm64, argm64)
    mym64 = sign_pi8(argm64, argm64)
    mym64 = sign_pi16(argm64, argm64)
    mym64 = sign_pi32(argm64, argm64)
    mym64 = alignr_pi8(argm64, argm64, 1)
  mym128i = alignr_epi8(argm128i, argm128i, 1)
  mym128i = shuffle_epi8(argm128i, argm128i)
  mym128i = sign_epi8(argm128i, argm128i)
  mym128i = sign_epi16(argm128i, argm128i)
  mym128i = sign_epi32(argm128i, argm128i)
  mym128i = abs_epi8(argm128i)
  mym128i = abs_epi16(argm128i)
  mym128i = abs_epi32(argm128i)
  mym128i = hadd_epi16(argm128i, argm128i)
  mym128i = hadd_epi32(argm128i, argm128i)
  mym128i = hadds_epi16(argm128i, argm128i)
  mym128i = hsub_epi16(argm128i, argm128i)
  mym128i = hsub_epi32(argm128i, argm128i)
  mym128i = hsubs_epi16(argm128i, argm128i)
  mym128i = maddubs_epi16(argm128i, argm128i)
  mym128i = mulhrs_epi16(argm128i, argm128i)

