#
#
#          Nimrod's x86 sse41 intrinsics
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

proc blendv_pd*(V1: m128d, V2: m128d, M: m128d): m128d
  {.importc: "_mm_blendv_pd ", header: "smmintrin.h".}
  ## Exposes _mm_blendv_pd  intrinsics

proc blendv_ps*(V1: m128, V2: m128, M: m128): m128
  {.importc: "_mm_blendv_ps ", header: "smmintrin.h".}
  ## Exposes _mm_blendv_ps  intrinsics

proc blendv_epi8*(V1: m128i, V2: m128i, M: m128i): m128i
  {.importc: "_mm_blendv_epi8 ", header: "smmintrin.h".}
  ## Exposes _mm_blendv_epi8  intrinsics

proc mullo_epi32*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_mullo_epi32 ", header: "smmintrin.h".}
  ## Exposes _mm_mullo_epi32  intrinsics

proc mul_epi32*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_mul_epi32 ", header: "smmintrin.h".}
  ## Exposes _mm_mul_epi32  intrinsics

proc stream_load_si128*(V: ptr m128i): m128i
  {.importc: "_mm_stream_load_si128 ", header: "smmintrin.h".}
  ## Exposes _mm_stream_load_si128  intrinsics

proc min_epi8*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_min_epi8 ", header: "smmintrin.h".}
  ## Exposes _mm_min_epi8  intrinsics

proc max_epi8*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_max_epi8 ", header: "smmintrin.h".}
  ## Exposes _mm_max_epi8  intrinsics

proc min_epu16*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_min_epu16 ", header: "smmintrin.h".}
  ## Exposes _mm_min_epu16  intrinsics

proc max_epu16*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_max_epu16 ", header: "smmintrin.h".}
  ## Exposes _mm_max_epu16  intrinsics

proc min_epi32*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_min_epi32 ", header: "smmintrin.h".}
  ## Exposes _mm_min_epi32  intrinsics

proc max_epi32*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_max_epi32 ", header: "smmintrin.h".}
  ## Exposes _mm_max_epi32  intrinsics

proc min_epu32*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_min_epu32 ", header: "smmintrin.h".}
  ## Exposes _mm_min_epu32  intrinsics

proc max_epu32*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_max_epu32 ", header: "smmintrin.h".}
  ## Exposes _mm_max_epu32  intrinsics

proc testz_si128*(M: m128i, V: m128i): int32
  {.importc: "_mm_testz_si128", header: "smmintrin.h".}
  ## Exposes _mm_testz_si128 intrinsics

proc testc_si128*(M: m128i, V: m128i): int32
  {.importc: "_mm_testc_si128", header: "smmintrin.h".}
  ## Exposes _mm_testc_si128 intrinsics

proc testnzc_si128*(M: m128i, V: m128i): int32
  {.importc: "_mm_testnzc_si128", header: "smmintrin.h".}
  ## Exposes _mm_testnzc_si128 intrinsics

proc cmpeq_epi64*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_cmpeq_epi64", header: "smmintrin.h".}
  ## Exposes _mm_cmpeq_epi64 intrinsics

proc cvtepi8_epi16*(V: m128i): m128i
  {.importc: "_mm_cvtepi8_epi16", header: "smmintrin.h".}
  ## Exposes _mm_cvtepi8_epi16 intrinsics

proc cvtepi8_epi32*(V: m128i): m128i
  {.importc: "_mm_cvtepi8_epi32", header: "smmintrin.h".}
  ## Exposes _mm_cvtepi8_epi32 intrinsics

proc cvtepi8_epi64*(V: m128i): m128i
  {.importc: "_mm_cvtepi8_epi64", header: "smmintrin.h".}
  ## Exposes _mm_cvtepi8_epi64 intrinsics

proc cvtepi16_epi32*(V: m128i): m128i
  {.importc: "_mm_cvtepi16_epi32", header: "smmintrin.h".}
  ## Exposes _mm_cvtepi16_epi32 intrinsics

proc cvtepi16_epi64*(V: m128i): m128i
  {.importc: "_mm_cvtepi16_epi64", header: "smmintrin.h".}
  ## Exposes _mm_cvtepi16_epi64 intrinsics

proc cvtepi32_epi64*(V: m128i): m128i
  {.importc: "_mm_cvtepi32_epi64", header: "smmintrin.h".}
  ## Exposes _mm_cvtepi32_epi64 intrinsics

proc cvtepu8_epi16*(V: m128i): m128i
  {.importc: "_mm_cvtepu8_epi16", header: "smmintrin.h".}
  ## Exposes _mm_cvtepu8_epi16 intrinsics

proc cvtepu8_epi32*(V: m128i): m128i
  {.importc: "_mm_cvtepu8_epi32", header: "smmintrin.h".}
  ## Exposes _mm_cvtepu8_epi32 intrinsics

proc cvtepu8_epi64*(V: m128i): m128i
  {.importc: "_mm_cvtepu8_epi64", header: "smmintrin.h".}
  ## Exposes _mm_cvtepu8_epi64 intrinsics

proc cvtepu16_epi32*(V: m128i): m128i
  {.importc: "_mm_cvtepu16_epi32", header: "smmintrin.h".}
  ## Exposes _mm_cvtepu16_epi32 intrinsics

proc cvtepu16_epi64*(V: m128i): m128i
  {.importc: "_mm_cvtepu16_epi64", header: "smmintrin.h".}
  ## Exposes _mm_cvtepu16_epi64 intrinsics

proc cvtepu32_epi64*(V: m128i): m128i
  {.importc: "_mm_cvtepu32_epi64", header: "smmintrin.h".}
  ## Exposes _mm_cvtepu32_epi64 intrinsics

proc packus_epi32*(V1: m128i, V2: m128i): m128i
  {.importc: "_mm_packus_epi32", header: "smmintrin.h".}
  ## Exposes _mm_packus_epi32 intrinsics

proc minpos_epu16*(V: m128i): m128i
  {.importc: "_mm_minpos_epu16", header: "smmintrin.h".}
  ## Exposes _mm_minpos_epu16 intrinsics

proc ceil_ps*(a: m128): m128
  {.importc: "_mm_ceil_ps", header: "smmintrin.h".}
  ## Exposes _mm_ceil_ps intrinsics

proc ceil_pd*(a: m128d): m128d
  {.importc: "_mm_ceil_pd", header: "smmintrin.h".}
  ## Exposes _mm_ceil_pd intrinsics

proc ceil_ss*(a: m128, b: m128): m128
  {.importc: "_mm_ceil_ss", header: "smmintrin.h".}
  ## Exposes _mm_ceil_ss intrinsics

proc ceil_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_ceil_sd", header: "smmintrin.h".}
  ## Exposes _mm_ceil_sd intrinsics

proc floor_ps*(a: m128): m128
  {.importc: "_mm_floor_ps", header: "smmintrin.h".}
  ## Exposes _mm_floor_ps intrinsics

proc floor_pd*(a: m128d): m128d
  {.importc: "_mm_floor_pd", header: "smmintrin.h".}
  ## Exposes _mm_floor_pd intrinsics

proc floor_ss*(a: m128, b: m128): m128
  {.importc: "_mm_floor_ss", header: "smmintrin.h".}
  ## Exposes _mm_floor_ss intrinsics

proc floor_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_floor_sd", header: "smmintrin.h".}
  ## Exposes _mm_floor_sd intrinsics

proc round_ps*(a: m128, b: int32): m128
  {.importc: "_mm_round_ps", header: "smmintrin.h".}
  ## Exposes _mm_round_ps intrinsics

proc round_pd*(a: m128d, b: int32): m128d
  {.importc: "_mm_round_pd", header: "smmintrin.h".}
  ## Exposes _mm_round_pd intrinsics

proc round_ss*(a: m128, b: m128, c: int32): m128
  {.importc: "_mm_round_ss", header: "smmintrin.h".}
  ## Exposes _mm_round_ss intrinsics

proc round_sd*(a: m128d, b: m128d, c: int32): m128d
  {.importc: "_mm_round_sd", header: "smmintrin.h".}
  ## Exposes _mm_round_sd intrinsics

proc blend_ps*(a: m128, b: m128, c: int32): m128
  {.importc: "_mm_blend_ps", header: "smmintrin.h".}
  ## Exposes _mm_blend_ps intrinsics

proc blend_pd*(a: m128d, b: m128d, c: int32): m128d
  {.importc: "_mm_blend_pd", header: "smmintrin.h".}
  ## Exposes _mm_blend_pd intrinsics

proc blend_epi16*(a: m128i, b: m128i, c: int32): m128i
  {.importc: "_mm_blend_epi16", header: "smmintrin.h".}
  ## Exposes _mm_blend_epi16 intrinsics

proc dp_ps*(a: m128, b: m128, c: int32): m128
  {.importc: "_mm_dp_ps", header: "smmintrin.h".}
  ## Exposes _mm_dp_ps intrinsics

proc dp_pd*(a: m128d, b: m128d, c: int32): m128d
  {.importc: "_mm_dp_pd", header: "smmintrin.h".}
  ## Exposes _mm_dp_pd intrinsics

proc insert_ps*(a: m128, b: m128, c: int32): m128
  {.importc: "_mm_insert_ps", header: "smmintrin.h".}
  ## Exposes _mm_insert_ps intrinsics

proc extract_ps*(a: m128, b: int32): int32
  {.importc: "_mm_extract_ps", header: "smmintrin.h".}
  ## Exposes _mm_extract_ps intrinsics

proc insert_epi8*(a: m128i, b: int32, c: int32): m128i
  {.importc: "_mm_insert_epi8", header: "smmintrin.h".}
  ## Exposes _mm_insert_epi8 intrinsics

proc insert_epi32*(a: m128i, b: int32, c: int32): m128i
  {.importc: "_mm_insert_epi32", header: "smmintrin.h".}
  ## Exposes _mm_insert_epi32 intrinsics

when defined(x86_64):
  proc insert_epi64*(a: m128i, b: int32, c: int32): m128i
    {.importc: "_mm_insert_epi64", header: "smmintrin.h".}
    ## Exposes _mm_insert_epi64 intrinsics

proc extract_epi8*(a: m128i, b: int32): int32
  {.importc: "_mm_extract_epi8", header: "smmintrin.h".}
  ## Exposes _mm_extract_epi8 intrinsics

proc extract_epi32*(a: m128i, b: int32): int32
  {.importc: "_mm_extract_epi32", header: "smmintrin.h".}
  ## Exposes _mm_extract_epi32 intrinsics

when defined(x86_64):
  proc extract_epi64*(a: m128i, b: int32): int32
    {.importc: "_mm_extract_epi64", header: "smmintrin.h".}
    ## Exposes _mm_extract_epi64 intrinsics

proc mpsadbw_epu8*(a: m128i, b: m128i, c: int32): m128i
  {.importc: "_mm_mpsadbw_epu8", header: "smmintrin.h".}
  ## Exposes _mm_mpsadbw_epu8 intrinsics

# Export all smmintrin.h constants
const FROUND_TO_NEAREST_INT* = 0x00
const FROUND_TO_NEG_INF* = 0x01
const FROUND_TO_POS_INF* = 0x02
const FROUND_TO_ZERO* = 0x03
const FROUND_CUR_DIRECTION* = 0x04
const FROUND_RAISE_EXC* = 0x00
const FROUND_NO_EXC* = 0x08
const FROUND_NINT* = FROUND_RAISE_EXC or FROUND_TO_NEAREST_INT
const FROUND_FLOOR* = FROUND_RAISE_EXC or FROUND_TO_NEG_INF
const FROUND_CEIL* = FROUND_RAISE_EXC or FROUND_TO_POS_INF
const FROUND_TRUNC* = FROUND_RAISE_EXC or FROUND_TO_ZERO
const FROUND_RINT* = FROUND_RAISE_EXC or FROUND_CUR_DIRECTION
const FROUND_NEARBYINT* = FROUND_NO_EXC or FROUND_CUR_DIRECTION

# Assert we generate proper C code
when isMainModule:
  var myint32 : int32 = 2;
  var mym128 = set1_ps(1.0)
  var mym128i = setr_epi32(1,2,3,4)
  var mym128d = set1_pd(1.0)
  var argm128 = set1_ps(1.0)
  var argm128i = setr_epi32(1,2,3,4)
  var argm128d = set1_pd(1.0)
  var argptrm128i : ptr m128i = addr(argm128i)

  mym128d = blendv_pd(argm128d, argm128d, argm128d)
  mym128 = blendv_ps(argm128, argm128, argm128)
  mym128i = blendv_epi8(argm128i, argm128i, argm128i)
  mym128i = mullo_epi32(argm128i, argm128i)
  mym128i = mul_epi32(argm128i, argm128i)
  mym128i = stream_load_si128(argptrm128i)
  mym128i = min_epi8(argm128i, argm128i)
  mym128i = max_epi8(argm128i, argm128i)
  mym128i = min_epu16(argm128i, argm128i)
  mym128i = max_epu16(argm128i, argm128i)
  mym128i = min_epi32(argm128i, argm128i)
  mym128i = max_epi32(argm128i, argm128i)
  mym128i = min_epu32(argm128i, argm128i)
  mym128i = max_epu32(argm128i, argm128i)
  myint32 = testz_si128(argm128i, argm128i)
  myint32 = testc_si128(argm128i, argm128i)
  myint32 = testnzc_si128(argm128i, argm128i)
  mym128i = cmpeq_epi64(argm128i, argm128i)
  mym128i = cvtepi8_epi16(argm128i)
  mym128i = cvtepi8_epi32(argm128i)
  mym128i = cvtepi8_epi64(argm128i)
  mym128i = cvtepi16_epi32(argm128i)
  mym128i = cvtepi16_epi64(argm128i)
  mym128i = cvtepi32_epi64(argm128i)
  mym128i = cvtepu8_epi16(argm128i)
  mym128i = cvtepu8_epi32(argm128i)
  mym128i = cvtepu8_epi64(argm128i)
  mym128i = cvtepu16_epi32(argm128i)
  mym128i = cvtepu16_epi64(argm128i)
  mym128i = cvtepu32_epi64(argm128i)
  mym128i = packus_epi32(argm128i, argm128i)
  mym128i = minpos_epu16(argm128i)
  mym128 = ceil_ps(argm128)
  mym128d = ceil_pd(argm128d)
  mym128 = ceil_ss(argm128, argm128)
  mym128d = ceil_sd(argm128d, argm128d)
  mym128 = floor_ps(argm128)
  mym128d = floor_pd(argm128d)
  mym128 = floor_ss(argm128, argm128)
  mym128d = floor_sd(argm128d, argm128d)
  mym128 = round_ps(argm128, 1)
  mym128d = round_pd(argm128d, 1)
  mym128 = round_ss(argm128, argm128, 1)
  mym128d = round_sd(argm128d, argm128d, 1)
  mym128 = blend_ps(argm128, argm128, 1)
  mym128d = blend_pd(argm128d, argm128d, 1)
  mym128i = blend_epi16(argm128i, argm128i, 1)
  mym128 = dp_ps(argm128, argm128, 1)
  mym128d = dp_pd(argm128d, argm128d, 1)
  mym128 = insert_ps(argm128, argm128, 1)
  myint32 = extract_ps(argm128, 1)
  mym128i = insert_epi8(argm128i, 1, 1)
  mym128i = insert_epi32(argm128i, 1, 1)
  when defined(x86_64):
    mym128i = insert_epi64(argm128i, 1, 1)
  myint32 = extract_epi8(argm128i, 1)
  myint32 = extract_epi32(argm128i, 1)
  when defined(x86_64):
    myint32 = extract_epi64(argm128i, 1)
  mym128i = mpsadbw_epu8(argm128i, argm128i, 1)

