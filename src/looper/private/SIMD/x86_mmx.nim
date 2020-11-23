#
#
#          Nimrod's x86 mmx intrinsics
#        (c) Copyright 2014 Ben Segovia
#
#    See the file copying.txt, included in this
#    distribution, for details about the copyright.
#

# MSVC does not support MMX on 64 bits target
const vcc64Bits = defined(vcc) and defined(x86_64)

when not vcc64Bits:
  type m64* {.importc: "__m64", header: "mmintrin.h".} = object

  proc empty*(): void
    {.importc: "_mm_empty", header: "mmintrin.h".}
    ## Exposes _mm_empty intrinsics

  proc cvtsi32_si64*(i: int32): m64
    {.importc: "_mm_cvtsi32_si64", header: "mmintrin.h".}
    ## Exposes _mm_cvtsi32_si64 intrinsics

  proc cvtsi64_si32*(m: m64): int32
    {.importc: "_mm_cvtsi64_si32", header: "mmintrin.h".}
    ## Exposes _mm_cvtsi64_si32 intrinsics

  proc packs_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_packs_pi16", header: "mmintrin.h".}
    ## Exposes _mm_packs_pi16 intrinsics

  proc packs_pi32*(m1: m64, m2: m64): m64
    {.importc: "_mm_packs_pi32", header: "mmintrin.h".}
    ## Exposes _mm_packs_pi32 intrinsics

  proc packs_pu16*(m1: m64, m2: m64): m64
    {.importc: "_mm_packs_pu16", header: "mmintrin.h".}
    ## Exposes _mm_packs_pu16 intrinsics

  proc unpackhi_pi8*(m1: m64, m2: m64): m64
    {.importc: "_mm_unpackhi_pi8", header: "mmintrin.h".}
    ## Exposes _mm_unpackhi_pi8 intrinsics

  proc unpackhi_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_unpackhi_pi16", header: "mmintrin.h".}
    ## Exposes _mm_unpackhi_pi16 intrinsics

  proc unpackhi_pi32*(m1: m64, m2: m64): m64
    {.importc: "_mm_unpackhi_pi32", header: "mmintrin.h".}
    ## Exposes _mm_unpackhi_pi32 intrinsics

  proc unpacklo_pi8*(m1: m64, m2: m64): m64
    {.importc: "_mm_unpacklo_pi8", header: "mmintrin.h".}
    ## Exposes _mm_unpacklo_pi8 intrinsics

  proc unpacklo_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_unpacklo_pi16", header: "mmintrin.h".}
    ## Exposes _mm_unpacklo_pi16 intrinsics

  proc unpacklo_pi32*(m1: m64, m2: m64): m64
    {.importc: "_mm_unpacklo_pi32", header: "mmintrin.h".}
    ## Exposes _mm_unpacklo_pi32 intrinsics

  proc add_pi8*(m1: m64, m2: m64): m64
    {.importc: "_mm_add_pi8", header: "mmintrin.h".}
    ## Exposes _mm_add_pi8 intrinsics

  proc add_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_add_pi16", header: "mmintrin.h".}
    ## Exposes _mm_add_pi16 intrinsics

  proc add_pi32*(m1: m64, m2: m64): m64
    {.importc: "_mm_add_pi32", header: "mmintrin.h".}
    ## Exposes _mm_add_pi32 intrinsics

  proc adds_pi8*(m1: m64, m2: m64): m64
    {.importc: "_mm_adds_pi8", header: "mmintrin.h".}
    ## Exposes _mm_adds_pi8 intrinsics

  proc adds_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_adds_pi16", header: "mmintrin.h".}
    ## Exposes _mm_adds_pi16 intrinsics

  proc adds_pu8*(m1: m64, m2: m64): m64
    {.importc: "_mm_adds_pu8", header: "mmintrin.h".}
    ## Exposes _mm_adds_pu8 intrinsics

  proc adds_pu16*(m1: m64, m2: m64): m64
    {.importc: "_mm_adds_pu16", header: "mmintrin.h".}
    ## Exposes _mm_adds_pu16 intrinsics

  proc sub_pi8*(m1: m64, m2: m64): m64
    {.importc: "_mm_sub_pi8", header: "mmintrin.h".}
    ## Exposes _mm_sub_pi8 intrinsics

  proc sub_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_sub_pi16", header: "mmintrin.h".}
    ## Exposes _mm_sub_pi16 intrinsics

  proc sub_pi32*(m1: m64, m2: m64): m64
    {.importc: "_mm_sub_pi32", header: "mmintrin.h".}
    ## Exposes _mm_sub_pi32 intrinsics

  proc subs_pi8*(m1: m64, m2: m64): m64
    {.importc: "_mm_subs_pi8", header: "mmintrin.h".}
    ## Exposes _mm_subs_pi8 intrinsics

  proc subs_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_subs_pi16", header: "mmintrin.h".}
    ## Exposes _mm_subs_pi16 intrinsics

  proc subs_pu8*(m1: m64, m2: m64): m64
    {.importc: "_mm_subs_pu8", header: "mmintrin.h".}
    ## Exposes _mm_subs_pu8 intrinsics

  proc subs_pu16*(m1: m64, m2: m64): m64
    {.importc: "_mm_subs_pu16", header: "mmintrin.h".}
    ## Exposes _mm_subs_pu16 intrinsics

  proc madd_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_madd_pi16", header: "mmintrin.h".}
    ## Exposes _mm_madd_pi16 intrinsics

  proc mulhi_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_mulhi_pi16", header: "mmintrin.h".}
    ## Exposes _mm_mulhi_pi16 intrinsics

  proc mullo_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_mullo_pi16", header: "mmintrin.h".}
    ## Exposes _mm_mullo_pi16 intrinsics

  proc sll_pi16*(m: m64, count: m64): m64
    {.importc: "_mm_sll_pi16", header: "mmintrin.h".}
    ## Exposes _mm_sll_pi16 intrinsics

  proc slli_pi16*(m: m64, count: int32): m64
    {.importc: "_mm_slli_pi16", header: "mmintrin.h".}
    ## Exposes _mm_slli_pi16 intrinsics

  proc sll_pi32*(m: m64, count: m64): m64
    {.importc: "_mm_sll_pi32", header: "mmintrin.h".}
    ## Exposes _mm_sll_pi32 intrinsics

  proc slli_pi32*(m: m64, count: int32): m64
    {.importc: "_mm_slli_pi32", header: "mmintrin.h".}
    ## Exposes _mm_slli_pi32 intrinsics

  proc sll_si64*(m: m64, count: m64): m64
    {.importc: "_mm_sll_si64", header: "mmintrin.h".}
    ## Exposes _mm_sll_si64 intrinsics

  proc slli_si64*(m: m64, count: int32): m64
    {.importc: "_mm_slli_si64", header: "mmintrin.h".}
    ## Exposes _mm_slli_si64 intrinsics

  proc sra_pi16*(m: m64, count: m64): m64
    {.importc: "_mm_sra_pi16", header: "mmintrin.h".}
    ## Exposes _mm_sra_pi16 intrinsics

  proc srai_pi16*(m: m64, count: int32): m64
    {.importc: "_mm_srai_pi16", header: "mmintrin.h".}
    ## Exposes _mm_srai_pi16 intrinsics

  proc sra_pi32*(m: m64, count: m64): m64
    {.importc: "_mm_sra_pi32", header: "mmintrin.h".}
    ## Exposes _mm_sra_pi32 intrinsics

  proc srai_pi32*(m: m64, count: int32): m64
    {.importc: "_mm_srai_pi32", header: "mmintrin.h".}
    ## Exposes _mm_srai_pi32 intrinsics

  proc srl_pi16*(m: m64, count: m64): m64
    {.importc: "_mm_srl_pi16", header: "mmintrin.h".}
    ## Exposes _mm_srl_pi16 intrinsics

  proc srli_pi16*(m: m64, count: int32): m64
    {.importc: "_mm_srli_pi16", header: "mmintrin.h".}
    ## Exposes _mm_srli_pi16 intrinsics

  proc srl_pi32*(m: m64, count: m64): m64
    {.importc: "_mm_srl_pi32", header: "mmintrin.h".}
    ## Exposes _mm_srl_pi32 intrinsics

  proc srli_pi32*(m: m64, count: int32): m64
    {.importc: "_mm_srli_pi32", header: "mmintrin.h".}
    ## Exposes _mm_srli_pi32 intrinsics

  proc srl_si64*(m: m64, count: m64): m64
    {.importc: "_mm_srl_si64", header: "mmintrin.h".}
    ## Exposes _mm_srl_si64 intrinsics

  proc srli_si64*(m: m64, count: int32): m64
    {.importc: "_mm_srli_si64", header: "mmintrin.h".}
    ## Exposes _mm_srli_si64 intrinsics

  proc and_si64*(m1: m64, m2: m64): m64
    {.importc: "_mm_and_si64", header: "mmintrin.h".}
    ## Exposes _mm_and_si64 intrinsics

  proc andnot_si64*(m1: m64, m2: m64): m64
    {.importc: "_mm_andnot_si64", header: "mmintrin.h".}
    ## Exposes _mm_andnot_si64 intrinsics

  proc or_si64*(m1: m64, m2: m64): m64
    {.importc: "_mm_or_si64", header: "mmintrin.h".}
    ## Exposes _mm_or_si64 intrinsics

  proc xor_si64*(m1: m64, m2: m64): m64
    {.importc: "_mm_xor_si64", header: "mmintrin.h".}
    ## Exposes _mm_xor_si64 intrinsics

  proc cmpeq_pi8*(m1: m64, m2: m64): m64
    {.importc: "_mm_cmpeq_pi8", header: "mmintrin.h".}
    ## Exposes _mm_cmpeq_pi8 intrinsics

  proc cmpeq_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_cmpeq_pi16", header: "mmintrin.h".}
    ## Exposes _mm_cmpeq_pi16 intrinsics

  proc cmpeq_pi32*(m1: m64, m2: m64): m64
    {.importc: "_mm_cmpeq_pi32", header: "mmintrin.h".}
    ## Exposes _mm_cmpeq_pi32 intrinsics

  proc cmpgt_pi8*(m1: m64, m2: m64): m64
    {.importc: "_mm_cmpgt_pi8", header: "mmintrin.h".}
    ## Exposes _mm_cmpgt_pi8 intrinsics

  proc cmpgt_pi16*(m1: m64, m2: m64): m64
    {.importc: "_mm_cmpgt_pi16", header: "mmintrin.h".}
    ## Exposes _mm_cmpgt_pi16 intrinsics

  proc cmpgt_pi32*(m1: m64, m2: m64): m64
    {.importc: "_mm_cmpgt_pi32", header: "mmintrin.h".}
    ## Exposes _mm_cmpgt_pi32 intrinsics

  proc setzero_si64*(): m64
    {.importc: "_mm_setzero_si64", header: "mmintrin.h".}
    ## Exposes _mm_setzero_si64 intrinsics

  proc set_pi32*(i1: int32, i0: int32): m64
    {.importc: "_mm_set_pi32", header: "mmintrin.h".}
    ## Exposes _mm_set_pi32 intrinsics

  proc set_pi16*(s3: int16, s2: int16, s1: int16, s0: int16): m64
    {.importc: "_mm_set_pi16", header: "mmintrin.h".}
    ## Exposes _mm_set_pi16 intrinsics

  proc set_pi8*(b7: int8, b6: int8, b5: int8, b4: int8, b3: int8, b2: int8, b1: int8, b0: int8): m64
    {.importc: "_mm_set_pi8", header: "mmintrin.h".}
    ## Exposes _mm_set_pi8 intrinsics

  proc set1_pi32*(i: int32): m64
    {.importc: "_mm_set1_pi32", header: "mmintrin.h".}
    ## Exposes _mm_set1_pi32 intrinsics

  proc set1_pi16*(w: int16): m64
    {.importc: "_mm_set1_pi16", header: "mmintrin.h".}
    ## Exposes _mm_set1_pi16 intrinsics

  proc set1_pi8*(b: int8): m64
    {.importc: "_mm_set1_pi8", header: "mmintrin.h".}
    ## Exposes _mm_set1_pi8 intrinsics

  proc setr_pi32*(i0: int32, i1: int32): m64
    {.importc: "_mm_setr_pi32", header: "mmintrin.h".}
    ## Exposes _mm_setr_pi32 intrinsics

  proc setr_pi16*(w0: int16, w1: int16, w2: int16, w3: int16): m64
    {.importc: "_mm_setr_pi16", header: "mmintrin.h".}
    ## Exposes _mm_setr_pi16 intrinsics

  proc setr_pi8*(b0: int8, b1: int8, b2: int8, b3: int8, b4: int8, b5: int8, b6: int8, b7: int8): m64
    {.importc: "_mm_setr_pi8", header: "mmintrin.h".}
    ## Exposes _mm_setr_pi8 intrinsics

  # Assert we generate proper C code
  when isMainModule:
    var myint32 : int32 = 2;
    var mym64 = set1_pi32(1)
    var argint8 : int8 = 1;
    var argint16 : int16 = 2;
    var argm64 = set1_pi32(1)

    empty()
    mym64 = cvtsi32_si64(1)
    myint32 = cvtsi64_si32(argm64)
    mym64 = packs_pi16(argm64, argm64)
    mym64 = packs_pi32(argm64, argm64)
    mym64 = packs_pu16(argm64, argm64)
    mym64 = unpackhi_pi8(argm64, argm64)
    mym64 = unpackhi_pi16(argm64, argm64)
    mym64 = unpackhi_pi32(argm64, argm64)
    mym64 = unpacklo_pi8(argm64, argm64)
    mym64 = unpacklo_pi16(argm64, argm64)
    mym64 = unpacklo_pi32(argm64, argm64)
    mym64 = add_pi8(argm64, argm64)
    mym64 = add_pi16(argm64, argm64)
    mym64 = add_pi32(argm64, argm64)
    mym64 = adds_pi8(argm64, argm64)
    mym64 = adds_pi16(argm64, argm64)
    mym64 = adds_pu8(argm64, argm64)
    mym64 = adds_pu16(argm64, argm64)
    mym64 = sub_pi8(argm64, argm64)
    mym64 = sub_pi16(argm64, argm64)
    mym64 = sub_pi32(argm64, argm64)
    mym64 = subs_pi8(argm64, argm64)
    mym64 = subs_pi16(argm64, argm64)
    mym64 = subs_pu8(argm64, argm64)
    mym64 = subs_pu16(argm64, argm64)
    mym64 = madd_pi16(argm64, argm64)
    mym64 = mulhi_pi16(argm64, argm64)
    mym64 = mullo_pi16(argm64, argm64)
    mym64 = sll_pi16(argm64, argm64)
    mym64 = slli_pi16(argm64, 1)
    mym64 = sll_pi32(argm64, argm64)
    mym64 = slli_pi32(argm64, 1)
    mym64 = sll_si64(argm64, argm64)
    mym64 = slli_si64(argm64, 1)
    mym64 = sra_pi16(argm64, argm64)
    mym64 = srai_pi16(argm64, 1)
    mym64 = sra_pi32(argm64, argm64)
    mym64 = srai_pi32(argm64, 1)
    mym64 = srl_pi16(argm64, argm64)
    mym64 = srli_pi16(argm64, 1)
    mym64 = srl_pi32(argm64, argm64)
    mym64 = srli_pi32(argm64, 1)
    mym64 = srl_si64(argm64, argm64)
    mym64 = srli_si64(argm64, 1)
    mym64 = and_si64(argm64, argm64)
    mym64 = andnot_si64(argm64, argm64)
    mym64 = or_si64(argm64, argm64)
    mym64 = xor_si64(argm64, argm64)
    mym64 = cmpeq_pi8(argm64, argm64)
    mym64 = cmpeq_pi16(argm64, argm64)
    mym64 = cmpeq_pi32(argm64, argm64)
    mym64 = cmpgt_pi8(argm64, argm64)
    mym64 = cmpgt_pi16(argm64, argm64)
    mym64 = cmpgt_pi32(argm64, argm64)
    mym64 = setzero_si64()
    mym64 = set_pi32(1, 1)
    mym64 = set_pi16(argint16, argint16, argint16, argint16)
    mym64 = set_pi8(argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8)
    mym64 = set1_pi32(1)
    mym64 = set1_pi16(argint16)
    mym64 = set1_pi8(argint8)
    mym64 = setr_pi32(1, 1)
    mym64 = setr_pi16(argint16, argint16, argint16, argint16)
    mym64 = setr_pi8(argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8)

