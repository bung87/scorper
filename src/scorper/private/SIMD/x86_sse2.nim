#
#
#          Nimrod's x86 sse2 intrinsics
#        (c) Copyright 2014 Ben Segovia
#
#    See the file copying.txt, included in this
#    distribution, for details about the copyright.
#

const someGcc = defined(gcc) or defined(llvm_gcc) or defined(clang)
when someGcc:
  {.passC: "-msse -msse2".}
  {.passL: "-msse -msse2".}

# MSVC does not support MMX on 64 bits target
const vcc64Bits = defined(vcc) and defined(x86_64)

import x86_mmx
import x86_sse
type m128d* {.importc: "__m128d", header: "emmintrin.h".} = object
type m128i* {.importc: "__m128i", header: "emmintrin.h".} = object

proc add_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_add_sd", header: "emmintrin.h".}
  ## Exposes _mm_add_sd intrinsics

proc add_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_add_pd", header: "emmintrin.h".}
  ## Exposes _mm_add_pd intrinsics

proc sub_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_sub_sd", header: "emmintrin.h".}
  ## Exposes _mm_sub_sd intrinsics

proc sub_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_sub_pd", header: "emmintrin.h".}
  ## Exposes _mm_sub_pd intrinsics

proc mul_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_mul_sd", header: "emmintrin.h".}
  ## Exposes _mm_mul_sd intrinsics

proc mul_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_mul_pd", header: "emmintrin.h".}
  ## Exposes _mm_mul_pd intrinsics

proc div_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_div_sd", header: "emmintrin.h".}
  ## Exposes _mm_div_sd intrinsics

proc div_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_div_pd", header: "emmintrin.h".}
  ## Exposes _mm_div_pd intrinsics

proc sqrt_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_sqrt_sd", header: "emmintrin.h".}
  ## Exposes _mm_sqrt_sd intrinsics

proc sqrt_pd*(a: m128d): m128d
  {.importc: "_mm_sqrt_pd", header: "emmintrin.h".}
  ## Exposes _mm_sqrt_pd intrinsics

proc min_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_min_sd", header: "emmintrin.h".}
  ## Exposes _mm_min_sd intrinsics

proc min_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_min_pd", header: "emmintrin.h".}
  ## Exposes _mm_min_pd intrinsics

proc max_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_max_sd", header: "emmintrin.h".}
  ## Exposes _mm_max_sd intrinsics

proc max_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_max_pd", header: "emmintrin.h".}
  ## Exposes _mm_max_pd intrinsics

proc and_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_and_pd", header: "emmintrin.h".}
  ## Exposes _mm_and_pd intrinsics

proc andnot_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_andnot_pd", header: "emmintrin.h".}
  ## Exposes _mm_andnot_pd intrinsics

proc or_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_or_pd", header: "emmintrin.h".}
  ## Exposes _mm_or_pd intrinsics

proc xor_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_xor_pd", header: "emmintrin.h".}
  ## Exposes _mm_xor_pd intrinsics

proc cmpeq_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpeq_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpeq_pd intrinsics

proc cmplt_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmplt_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmplt_pd intrinsics

proc cmple_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmple_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmple_pd intrinsics

proc cmpgt_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpgt_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpgt_pd intrinsics

proc cmpge_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpge_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpge_pd intrinsics

proc cmpord_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpord_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpord_pd intrinsics

proc cmpunord_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpunord_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpunord_pd intrinsics

proc cmpneq_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpneq_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpneq_pd intrinsics

proc cmpnlt_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpnlt_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpnlt_pd intrinsics

proc cmpnle_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpnle_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpnle_pd intrinsics

proc cmpngt_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpngt_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpngt_pd intrinsics

proc cmpnge_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpnge_pd", header: "emmintrin.h".}
  ## Exposes _mm_cmpnge_pd intrinsics

proc cmpeq_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpeq_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpeq_sd intrinsics

proc cmplt_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmplt_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmplt_sd intrinsics

proc cmple_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmple_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmple_sd intrinsics

proc cmpgt_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpgt_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpgt_sd intrinsics

proc cmpge_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpge_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpge_sd intrinsics

proc cmpord_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpord_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpord_sd intrinsics

proc cmpunord_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpunord_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpunord_sd intrinsics

proc cmpneq_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpneq_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpneq_sd intrinsics

proc cmpnlt_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpnlt_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpnlt_sd intrinsics

proc cmpnle_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpnle_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpnle_sd intrinsics

proc cmpngt_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpngt_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpngt_sd intrinsics

proc cmpnge_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_cmpnge_sd", header: "emmintrin.h".}
  ## Exposes _mm_cmpnge_sd intrinsics

proc comieq_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_comieq_sd", header: "emmintrin.h".}
  ## Exposes _mm_comieq_sd intrinsics

proc comilt_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_comilt_sd", header: "emmintrin.h".}
  ## Exposes _mm_comilt_sd intrinsics

proc comile_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_comile_sd", header: "emmintrin.h".}
  ## Exposes _mm_comile_sd intrinsics

proc comigt_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_comigt_sd", header: "emmintrin.h".}
  ## Exposes _mm_comigt_sd intrinsics

proc comige_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_comige_sd", header: "emmintrin.h".}
  ## Exposes _mm_comige_sd intrinsics

proc comineq_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_comineq_sd", header: "emmintrin.h".}
  ## Exposes _mm_comineq_sd intrinsics

proc ucomieq_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_ucomieq_sd", header: "emmintrin.h".}
  ## Exposes _mm_ucomieq_sd intrinsics

proc ucomilt_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_ucomilt_sd", header: "emmintrin.h".}
  ## Exposes _mm_ucomilt_sd intrinsics

proc ucomile_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_ucomile_sd", header: "emmintrin.h".}
  ## Exposes _mm_ucomile_sd intrinsics

proc ucomigt_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_ucomigt_sd", header: "emmintrin.h".}
  ## Exposes _mm_ucomigt_sd intrinsics

proc ucomige_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_ucomige_sd", header: "emmintrin.h".}
  ## Exposes _mm_ucomige_sd intrinsics

proc ucomineq_sd*(a: m128d, b: m128d): int32
  {.importc: "_mm_ucomineq_sd", header: "emmintrin.h".}
  ## Exposes _mm_ucomineq_sd intrinsics

proc cvtpd_ps*(a: m128d): m128
  {.importc: "_mm_cvtpd_ps", header: "emmintrin.h".}
  ## Exposes _mm_cvtpd_ps intrinsics

proc cvtps_pd*(a: m128): m128d
  {.importc: "_mm_cvtps_pd", header: "emmintrin.h".}
  ## Exposes _mm_cvtps_pd intrinsics

proc cvtepi32_pd*(a: m128i): m128d
  {.importc: "_mm_cvtepi32_pd", header: "emmintrin.h".}
  ## Exposes _mm_cvtepi32_pd intrinsics

proc cvtpd_epi32*(a: m128d): m128i
  {.importc: "_mm_cvtpd_epi32", header: "emmintrin.h".}
  ## Exposes _mm_cvtpd_epi32 intrinsics

proc cvtsd_si32*(a: m128d): int32
  {.importc: "_mm_cvtsd_si32", header: "emmintrin.h".}
  ## Exposes _mm_cvtsd_si32 intrinsics

proc cvtsd_ss*(a: m128, b: m128d): m128
  {.importc: "_mm_cvtsd_ss", header: "emmintrin.h".}
  ## Exposes _mm_cvtsd_ss intrinsics

proc cvtsi32_sd*(a: m128d, b: int32): m128d
  {.importc: "_mm_cvtsi32_sd", header: "emmintrin.h".}
  ## Exposes _mm_cvtsi32_sd intrinsics

proc cvtss_sd*(a: m128d, b: m128): m128d
  {.importc: "_mm_cvtss_sd", header: "emmintrin.h".}
  ## Exposes _mm_cvtss_sd intrinsics

proc cvttpd_epi32*(a: m128d): m128i
  {.importc: "_mm_cvttpd_epi32", header: "emmintrin.h".}
  ## Exposes _mm_cvttpd_epi32 intrinsics

proc cvttsd_si32*(a: m128d): int32
  {.importc: "_mm_cvttsd_si32", header: "emmintrin.h".}
  ## Exposes _mm_cvttsd_si32 intrinsics

proc cvtsd_f64*(a: m128d): float64
  {.importc: "_mm_cvtsd_f64", header: "emmintrin.h".}
  ## Exposes _mm_cvtsd_f64 intrinsics

proc load_pd*(dp: ptr float64): m128d
  {.importc: "_mm_load_pd", header: "emmintrin.h".}
  ## Exposes _mm_load_pd intrinsics

proc load1_pd*(dp: ptr float64): m128d
  {.importc: "_mm_load1_pd", header: "emmintrin.h".}
  ## Exposes _mm_load1_pd intrinsics

proc loadr_pd*(dp: ptr float64): m128d
  {.importc: "_mm_loadr_pd", header: "emmintrin.h".}
  ## Exposes _mm_loadr_pd intrinsics

proc loadu_pd*(dp: ptr float64): m128d
  {.importc: "_mm_loadu_pd", header: "emmintrin.h".}
  ## Exposes _mm_loadu_pd intrinsics

proc load_sd*(dp: ptr float64): m128d
  {.importc: "_mm_load_sd", header: "emmintrin.h".}
  ## Exposes _mm_load_sd intrinsics

proc loadh_pd*(a: m128d, dp: ptr float64): m128d
  {.importc: "_mm_loadh_pd", header: "emmintrin.h".}
  ## Exposes _mm_loadh_pd intrinsics

proc loadl_pd*(a: m128d, dp: ptr float64): m128d
  {.importc: "_mm_loadl_pd", header: "emmintrin.h".}
  ## Exposes _mm_loadl_pd intrinsics

proc set_sd*(w: float64): m128d
  {.importc: "_mm_set_sd", header: "emmintrin.h".}
  ## Exposes _mm_set_sd intrinsics

proc set1_pd*(w: float64): m128d
  {.importc: "_mm_set1_pd", header: "emmintrin.h".}
  ## Exposes _mm_set1_pd intrinsics

proc set_pd*(w: float64, x: float64): m128d
  {.importc: "_mm_set_pd", header: "emmintrin.h".}
  ## Exposes _mm_set_pd intrinsics

proc setr_pd*(w: float64, x: float64): m128d
  {.importc: "_mm_setr_pd", header: "emmintrin.h".}
  ## Exposes _mm_setr_pd intrinsics

proc setzero_pd*(): m128d
  {.importc: "_mm_setzero_pd", header: "emmintrin.h".}
  ## Exposes _mm_setzero_pd intrinsics

proc move_sd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_move_sd", header: "emmintrin.h".}
  ## Exposes _mm_move_sd intrinsics

proc store_sd*(dp: ptr float64, a: m128d): void
  {.importc: "_mm_store_sd", header: "emmintrin.h".}
  ## Exposes _mm_store_sd intrinsics

proc store1_pd*(dp: ptr float64, a: m128d): void
  {.importc: "_mm_store1_pd", header: "emmintrin.h".}
  ## Exposes _mm_store1_pd intrinsics

proc store_pd*(dp: ptr float64, a: m128d): void
  {.importc: "_mm_store_pd", header: "emmintrin.h".}
  ## Exposes _mm_store_pd intrinsics

proc storeu_pd*(dp: ptr float64, a: m128d): void
  {.importc: "_mm_storeu_pd", header: "emmintrin.h".}
  ## Exposes _mm_storeu_pd intrinsics

proc storer_pd*(dp: ptr float64, a: m128d): void
  {.importc: "_mm_storer_pd", header: "emmintrin.h".}
  ## Exposes _mm_storer_pd intrinsics

proc storeh_pd*(dp: ptr float64, a: m128d): void
  {.importc: "_mm_storeh_pd", header: "emmintrin.h".}
  ## Exposes _mm_storeh_pd intrinsics

proc storel_pd*(dp: ptr float64, a: m128d): void
  {.importc: "_mm_storel_pd", header: "emmintrin.h".}
  ## Exposes _mm_storel_pd intrinsics

proc add_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_add_epi8", header: "emmintrin.h".}
  ## Exposes _mm_add_epi8 intrinsics

proc add_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_add_epi16", header: "emmintrin.h".}
  ## Exposes _mm_add_epi16 intrinsics

proc add_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_add_epi32", header: "emmintrin.h".}
  ## Exposes _mm_add_epi32 intrinsics

proc add_epi64*(a: m128i, b: m128i): m128i
  {.importc: "_mm_add_epi64", header: "emmintrin.h".}
  ## Exposes _mm_add_epi64 intrinsics

proc adds_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_adds_epi8", header: "emmintrin.h".}
  ## Exposes _mm_adds_epi8 intrinsics

proc adds_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_adds_epi16", header: "emmintrin.h".}
  ## Exposes _mm_adds_epi16 intrinsics

proc adds_epu8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_adds_epu8", header: "emmintrin.h".}
  ## Exposes _mm_adds_epu8 intrinsics

proc adds_epu16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_adds_epu16", header: "emmintrin.h".}
  ## Exposes _mm_adds_epu16 intrinsics

proc avg_epu8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_avg_epu8", header: "emmintrin.h".}
  ## Exposes _mm_avg_epu8 intrinsics

proc avg_epu16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_avg_epu16", header: "emmintrin.h".}
  ## Exposes _mm_avg_epu16 intrinsics

proc madd_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_madd_epi16", header: "emmintrin.h".}
  ## Exposes _mm_madd_epi16 intrinsics

proc max_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_max_epi16", header: "emmintrin.h".}
  ## Exposes _mm_max_epi16 intrinsics

proc max_epu8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_max_epu8", header: "emmintrin.h".}
  ## Exposes _mm_max_epu8 intrinsics

proc min_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_min_epi16", header: "emmintrin.h".}
  ## Exposes _mm_min_epi16 intrinsics

proc min_epu8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_min_epu8", header: "emmintrin.h".}
  ## Exposes _mm_min_epu8 intrinsics

proc mulhi_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_mulhi_epi16", header: "emmintrin.h".}
  ## Exposes _mm_mulhi_epi16 intrinsics

proc mulhi_epu16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_mulhi_epu16", header: "emmintrin.h".}
  ## Exposes _mm_mulhi_epu16 intrinsics

proc mullo_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_mullo_epi16", header: "emmintrin.h".}
  ## Exposes _mm_mullo_epi16 intrinsics

proc mul_epu32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_mul_epu32", header: "emmintrin.h".}
  ## Exposes _mm_mul_epu32 intrinsics

proc sad_epu8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_sad_epu8", header: "emmintrin.h".}
  ## Exposes _mm_sad_epu8 intrinsics

proc sub_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_sub_epi8", header: "emmintrin.h".}
  ## Exposes _mm_sub_epi8 intrinsics

proc sub_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_sub_epi16", header: "emmintrin.h".}
  ## Exposes _mm_sub_epi16 intrinsics

proc sub_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_sub_epi32", header: "emmintrin.h".}
  ## Exposes _mm_sub_epi32 intrinsics

proc sub_epi64*(a: m128i, b: m128i): m128i
  {.importc: "_mm_sub_epi64", header: "emmintrin.h".}
  ## Exposes _mm_sub_epi64 intrinsics

proc subs_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_subs_epi8", header: "emmintrin.h".}
  ## Exposes _mm_subs_epi8 intrinsics

proc subs_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_subs_epi16", header: "emmintrin.h".}
  ## Exposes _mm_subs_epi16 intrinsics

proc subs_epu8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_subs_epu8", header: "emmintrin.h".}
  ## Exposes _mm_subs_epu8 intrinsics

proc subs_epu16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_subs_epu16", header: "emmintrin.h".}
  ## Exposes _mm_subs_epu16 intrinsics

proc and_si128*(a: m128i, b: m128i): m128i
  {.importc: "_mm_and_si128", header: "emmintrin.h".}
  ## Exposes _mm_and_si128 intrinsics

proc andnot_si128*(a: m128i, b: m128i): m128i
  {.importc: "_mm_andnot_si128", header: "emmintrin.h".}
  ## Exposes _mm_andnot_si128 intrinsics

proc or_si128*(a: m128i, b: m128i): m128i
  {.importc: "_mm_or_si128", header: "emmintrin.h".}
  ## Exposes _mm_or_si128 intrinsics

proc xor_si128*(a: m128i, b: m128i): m128i
  {.importc: "_mm_xor_si128", header: "emmintrin.h".}
  ## Exposes _mm_xor_si128 intrinsics

proc slli_epi16*(a: m128i, count: int32): m128i
  {.importc: "_mm_slli_epi16", header: "emmintrin.h".}
  ## Exposes _mm_slli_epi16 intrinsics

proc sll_epi16*(a: m128i, count: m128i): m128i
  {.importc: "_mm_sll_epi16", header: "emmintrin.h".}
  ## Exposes _mm_sll_epi16 intrinsics

proc slli_epi32*(a: m128i, count: int32): m128i
  {.importc: "_mm_slli_epi32", header: "emmintrin.h".}
  ## Exposes _mm_slli_epi32 intrinsics

proc sll_epi32*(a: m128i, count: m128i): m128i
  {.importc: "_mm_sll_epi32", header: "emmintrin.h".}
  ## Exposes _mm_sll_epi32 intrinsics

proc slli_epi64*(a: m128i, count: int32): m128i
  {.importc: "_mm_slli_epi64", header: "emmintrin.h".}
  ## Exposes _mm_slli_epi64 intrinsics

proc sll_epi64*(a: m128i, count: m128i): m128i
  {.importc: "_mm_sll_epi64", header: "emmintrin.h".}
  ## Exposes _mm_sll_epi64 intrinsics

proc srai_epi16*(a: m128i, count: int32): m128i
  {.importc: "_mm_srai_epi16", header: "emmintrin.h".}
  ## Exposes _mm_srai_epi16 intrinsics

proc sra_epi16*(a: m128i, count: m128i): m128i
  {.importc: "_mm_sra_epi16", header: "emmintrin.h".}
  ## Exposes _mm_sra_epi16 intrinsics

proc srai_epi32*(a: m128i, count: int32): m128i
  {.importc: "_mm_srai_epi32", header: "emmintrin.h".}
  ## Exposes _mm_srai_epi32 intrinsics

proc sra_epi32*(a: m128i, count: m128i): m128i
  {.importc: "_mm_sra_epi32", header: "emmintrin.h".}
  ## Exposes _mm_sra_epi32 intrinsics

proc srli_epi16*(a: m128i, count: int32): m128i
  {.importc: "_mm_srli_epi16", header: "emmintrin.h".}
  ## Exposes _mm_srli_epi16 intrinsics

proc srl_epi16*(a: m128i, count: m128i): m128i
  {.importc: "_mm_srl_epi16", header: "emmintrin.h".}
  ## Exposes _mm_srl_epi16 intrinsics

proc srli_epi32*(a: m128i, count: int32): m128i
  {.importc: "_mm_srli_epi32", header: "emmintrin.h".}
  ## Exposes _mm_srli_epi32 intrinsics

proc srl_epi32*(a: m128i, count: m128i): m128i
  {.importc: "_mm_srl_epi32", header: "emmintrin.h".}
  ## Exposes _mm_srl_epi32 intrinsics

proc srli_epi64*(a: m128i, count: int32): m128i
  {.importc: "_mm_srli_epi64", header: "emmintrin.h".}
  ## Exposes _mm_srli_epi64 intrinsics

proc srl_epi64*(a: m128i, count: m128i): m128i
  {.importc: "_mm_srl_epi64", header: "emmintrin.h".}
  ## Exposes _mm_srl_epi64 intrinsics

proc cmpeq_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_cmpeq_epi8", header: "emmintrin.h".}
  ## Exposes _mm_cmpeq_epi8 intrinsics

proc cmpeq_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_cmpeq_epi16", header: "emmintrin.h".}
  ## Exposes _mm_cmpeq_epi16 intrinsics

proc cmpeq_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_cmpeq_epi32", header: "emmintrin.h".}
  ## Exposes _mm_cmpeq_epi32 intrinsics

proc cmpgt_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_cmpgt_epi8", header: "emmintrin.h".}
  ## Exposes _mm_cmpgt_epi8 intrinsics

proc cmpgt_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_cmpgt_epi16", header: "emmintrin.h".}
  ## Exposes _mm_cmpgt_epi16 intrinsics

proc cmpgt_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_cmpgt_epi32", header: "emmintrin.h".}
  ## Exposes _mm_cmpgt_epi32 intrinsics

proc cmplt_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_cmplt_epi8", header: "emmintrin.h".}
  ## Exposes _mm_cmplt_epi8 intrinsics

proc cmplt_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_cmplt_epi16", header: "emmintrin.h".}
  ## Exposes _mm_cmplt_epi16 intrinsics

proc cmplt_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_cmplt_epi32", header: "emmintrin.h".}
  ## Exposes _mm_cmplt_epi32 intrinsics

when defined(x86_64):
  proc cvtsi64_sd*(a: m128d, b: int64): m128d
    {.importc: "_mm_cvtsi64_sd", header: "emmintrin.h".}
    ## Exposes _mm_cvtsi64_sd intrinsics

  proc cvtsi64_si128*(a: int64): m128i
    {.importc: "_mm_cvtsi64_si128", header: "emmintrin.h".}
    ## Exposes _mm_cvtsi64_si128 intrinsics

  proc stream_si64*(p: ptr int64, a: int64): void
    {.importc: "_mm_stream_si64", header: "emmintrin.h".}
    ## Exposes _mm_stream_si64 intrinsics

proc cvtepi32_ps*(a: m128i): m128
  {.importc: "_mm_cvtepi32_ps", header: "emmintrin.h".}
  ## Exposes _mm_cvtepi32_ps intrinsics

proc cvtps_epi32*(a: m128): m128i
  {.importc: "_mm_cvtps_epi32", header: "emmintrin.h".}
  ## Exposes _mm_cvtps_epi32 intrinsics

proc cvttps_epi32*(a: m128): m128i
  {.importc: "_mm_cvttps_epi32", header: "emmintrin.h".}
  ## Exposes _mm_cvttps_epi32 intrinsics

proc cvtsi32_si128*(a: int32): m128i
  {.importc: "_mm_cvtsi32_si128", header: "emmintrin.h".}
  ## Exposes _mm_cvtsi32_si128 intrinsics

proc cvtsi128_si32*(a: m128i): int32
  {.importc: "_mm_cvtsi128_si32", header: "emmintrin.h".}
  ## Exposes _mm_cvtsi128_si32 intrinsics

proc load_si128*(p: ptr m128i): m128i
  {.importc: "_mm_load_si128", header: "emmintrin.h".}
  ## Exposes _mm_load_si128 intrinsics

proc loadu_si128*(p: ptr m128i): m128i
  {.importc: "_mm_loadu_si128", header: "emmintrin.h".}
  ## Exposes _mm_loadu_si128 intrinsics

proc loadl_epi64*(p: ptr m128i): m128i
  {.importc: "_mm_loadl_epi64", header: "emmintrin.h".}
  ## Exposes _mm_loadl_epi64 intrinsics

proc set_epi32*(i3: int32, i2: int32, i1: int32, i0: int32): m128i
  {.importc: "_mm_set_epi32", header: "emmintrin.h".}
  ## Exposes _mm_set_epi32 intrinsics

proc set_epi16*(w7: int16, w6: int16, w5: int16, w4: int16, w3: int16, w2: int16, w1: int16, w0: int16): m128i
  {.importc: "_mm_set_epi16", header: "emmintrin.h".}
  ## Exposes _mm_set_epi16 intrinsics

proc set_epi8*(b15: int8, b14: int8, b13: int8, b12: int8, b11: int8, b10: int8, b9: int8, b8: int8, b7: int8, b6: int8, b5: int8, b4: int8, b3: int8, b2: int8, b1: int8, b0: int8): m128i
  {.importc: "_mm_set_epi8", header: "emmintrin.h".}
  ## Exposes _mm_set_epi8 intrinsics

proc set1_epi32*(i: int32): m128i
  {.importc: "_mm_set1_epi32", header: "emmintrin.h".}
  ## Exposes _mm_set1_epi32 intrinsics

proc set1_epi16*(w: int16): m128i
  {.importc: "_mm_set1_epi16", header: "emmintrin.h".}
  ## Exposes _mm_set1_epi16 intrinsics

proc set1_epi8*(b: int8): m128i
  {.importc: "_mm_set1_epi8", header: "emmintrin.h".}
  ## Exposes _mm_set1_epi8 intrinsics

proc setr_epi32*(i0: int32, i1: int32, i2: int32, i3: int32): m128i
  {.importc: "_mm_setr_epi32", header: "emmintrin.h".}
  ## Exposes _mm_setr_epi32 intrinsics

proc setr_epi16*(w0: int16, w1: int16, w2: int16, w3: int16, w4: int16, w5: int16, w6: int16, w7: int16): m128i
  {.importc: "_mm_setr_epi16", header: "emmintrin.h".}
  ## Exposes _mm_setr_epi16 intrinsics

proc setr_epi8*(b0: int8, b1: int8, b2: int8, b3: int8, b4: int8, b5: int8, b6: int8, b7: int8, b8: int8, b9: int8, b10: int8, b11: int8, b12: int8, b13: int8, b14: int8, b15: int8): m128i
  {.importc: "_mm_setr_epi8", header: "emmintrin.h".}
  ## Exposes _mm_setr_epi8 intrinsics

proc setzero_si128*(): m128i
  {.importc: "_mm_setzero_si128", header: "emmintrin.h".}
  ## Exposes _mm_setzero_si128 intrinsics

proc store_si128*(p: ptr m128i, b: m128i): void
  {.importc: "_mm_store_si128", header: "emmintrin.h".}
  ## Exposes _mm_store_si128 intrinsics

proc storeu_si128*(p: ptr m128i, b: m128i): void
  {.importc: "_mm_storeu_si128", header: "emmintrin.h".}
  ## Exposes _mm_storeu_si128 intrinsics

proc maskmoveu_si128*(d: m128i, n: m128i, p: ptr int8): void
  {.importc: "_mm_maskmoveu_si128", header: "emmintrin.h".}
  ## Exposes _mm_maskmoveu_si128 intrinsics

proc storel_epi64*(p: ptr m128i, a: m128i): void
  {.importc: "_mm_storel_epi64", header: "emmintrin.h".}
  ## Exposes _mm_storel_epi64 intrinsics

proc stream_pd*(p: ptr float64, a: m128d): void
  {.importc: "_mm_stream_pd", header: "emmintrin.h".}
  ## Exposes _mm_stream_pd intrinsics

proc stream_si128*(p: ptr m128i, a: m128i): void
  {.importc: "_mm_stream_si128", header: "emmintrin.h".}
  ## Exposes _mm_stream_si128 intrinsics

proc stream_si32*(p: ptr int32, a: int32): void
  {.importc: "_mm_stream_si32", header: "emmintrin.h".}
  ## Exposes _mm_stream_si32 intrinsics

proc clflush*(p: ptr int8): void
  {.importc: "_mm_clflush", header: "emmintrin.h".}
  ## Exposes _mm_clflush intrinsics

proc lfence*(): void
  {.importc: "_mm_lfence", header: "emmintrin.h".}
  ## Exposes _mm_lfence intrinsics

proc mfence*(): void
  {.importc: "_mm_mfence", header: "emmintrin.h".}
  ## Exposes _mm_mfence intrinsics

proc packs_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_packs_epi16", header: "emmintrin.h".}
  ## Exposes _mm_packs_epi16 intrinsics

proc packs_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_packs_epi32", header: "emmintrin.h".}
  ## Exposes _mm_packs_epi32 intrinsics

proc packus_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_packus_epi16", header: "emmintrin.h".}
  ## Exposes _mm_packus_epi16 intrinsics

proc extract_epi16*(a: m128i, imm: int32): int32
  {.importc: "_mm_extract_epi16", header: "emmintrin.h".}
  ## Exposes _mm_extract_epi16 intrinsics

proc insert_epi16*(a: m128i, b: int32, imm: int32): m128i
  {.importc: "_mm_insert_epi16", header: "emmintrin.h".}
  ## Exposes _mm_insert_epi16 intrinsics

proc movemask_epi8*(a: m128i): int32
  {.importc: "_mm_movemask_epi8", header: "emmintrin.h".}
  ## Exposes _mm_movemask_epi8 intrinsics

proc unpackhi_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_unpackhi_epi8", header: "emmintrin.h".}
  ## Exposes _mm_unpackhi_epi8 intrinsics

proc unpackhi_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_unpackhi_epi16", header: "emmintrin.h".}
  ## Exposes _mm_unpackhi_epi16 intrinsics

proc unpackhi_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_unpackhi_epi32", header: "emmintrin.h".}
  ## Exposes _mm_unpackhi_epi32 intrinsics

proc unpackhi_epi64*(a: m128i, b: m128i): m128i
  {.importc: "_mm_unpackhi_epi64", header: "emmintrin.h".}
  ## Exposes _mm_unpackhi_epi64 intrinsics

proc unpacklo_epi8*(a: m128i, b: m128i): m128i
  {.importc: "_mm_unpacklo_epi8", header: "emmintrin.h".}
  ## Exposes _mm_unpacklo_epi8 intrinsics

proc unpacklo_epi16*(a: m128i, b: m128i): m128i
  {.importc: "_mm_unpacklo_epi16", header: "emmintrin.h".}
  ## Exposes _mm_unpacklo_epi16 intrinsics

proc unpacklo_epi32*(a: m128i, b: m128i): m128i
  {.importc: "_mm_unpacklo_epi32", header: "emmintrin.h".}
  ## Exposes _mm_unpacklo_epi32 intrinsics

proc unpacklo_epi64*(a: m128i, b: m128i): m128i
  {.importc: "_mm_unpacklo_epi64", header: "emmintrin.h".}
  ## Exposes _mm_unpacklo_epi64 intrinsics

proc move_epi64*(a: m128i): m128i
  {.importc: "_mm_move_epi64", header: "emmintrin.h".}
  ## Exposes _mm_move_epi64 intrinsics

proc unpackhi_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_unpackhi_pd", header: "emmintrin.h".}
  ## Exposes _mm_unpackhi_pd intrinsics

proc unpacklo_pd*(a: m128d, b: m128d): m128d
  {.importc: "_mm_unpacklo_pd", header: "emmintrin.h".}
  ## Exposes _mm_unpacklo_pd intrinsics

proc movemask_pd*(a: m128d): int32
  {.importc: "_mm_movemask_pd", header: "emmintrin.h".}
  ## Exposes _mm_movemask_pd intrinsics

proc castpd_ps*(a: m128d): m128
  {.importc: "_mm_castpd_ps", header: "emmintrin.h".}
  ## Exposes _mm_castpd_ps intrinsics

proc castpd_si128*(a: m128d): m128i
  {.importc: "_mm_castpd_si128", header: "emmintrin.h".}
  ## Exposes _mm_castpd_si128 intrinsics

proc castps_pd*(a: m128): m128d
  {.importc: "_mm_castps_pd", header: "emmintrin.h".}
  ## Exposes _mm_castps_pd intrinsics

proc castps_si128*(a: m128): m128i
  {.importc: "_mm_castps_si128", header: "emmintrin.h".}
  ## Exposes _mm_castps_si128 intrinsics

proc castsi128_ps*(a: m128i): m128
  {.importc: "_mm_castsi128_ps", header: "emmintrin.h".}
  ## Exposes _mm_castsi128_ps intrinsics

proc castsi128_pd*(a: m128i): m128d
  {.importc: "_mm_castsi128_pd", header: "emmintrin.h".}
  ## Exposes _mm_castsi128_pd intrinsics

proc pause*(): void
  {.importc: "_mm_pause", header: "emmintrin.h".}
  ## Exposes _mm_pause intrinsics

proc slli_si128*(a: m128i, b: int32): m128i
  {.importc: "_mm_slli_si128", header: "emmintrin.h".}
  ## Exposes _mm_slli_si128 intrinsics

proc srli_si128*(a: m128i, b: int32): m128i
  {.importc: "_mm_srli_si128", header: "emmintrin.h".}
  ## Exposes _mm_srli_si128 intrinsics

proc shuffle_epi32*(a: m128i, b: int32): m128i
  {.importc: "_mm_shuffle_epi32", header: "emmintrin.h".}
  ## Exposes _mm_shuffle_epi32 intrinsics

proc shufflelo_epi16*(a: m128i, b: int32): m128i
  {.importc: "_mm_shufflelo_epi16", header: "emmintrin.h".}
  ## Exposes _mm_shufflelo_epi16 intrinsics

proc shufflehi_epi16*(a: m128i, b: int32): m128i
  {.importc: "_mm_shufflehi_epi16", header: "emmintrin.h".}
  ## Exposes _mm_shufflehi_epi16 intrinsics

proc shuffle_pd*(a: m128d, b: m128d, c: int32): m128d
  {.importc: "_mm_shuffle_pd", header: "emmintrin.h".}
  ## Exposes _mm_shuffle_pd intrinsics

when not vcc64Bits:
  proc cvtpd_pi32*(a: m128d): m64
    {.importc: "_mm_cvtpd_pi32", header: "emmintrin.h".}
    ## Exposes _mm_cvtpd_pi32 intrinsics

  proc cvttpd_pi32*(a: m128d): m64
    {.importc: "_mm_cvttpd_pi32", header: "emmintrin.h".}
    ## Exposes _mm_cvttpd_pi32 intrinsics

  proc cvtpi32_pd*(a: m64): m128d
    {.importc: "_mm_cvtpi32_pd", header: "emmintrin.h".}
    ## Exposes _mm_cvtpi32_pd intrinsics

  proc add_si64*(a: m64, b: m64): m64
    {.importc: "_mm_add_si64", header: "emmintrin.h".}
    ## Exposes _mm_add_si64 intrinsics

  proc set_epi64*(q1: m64, q0: m64): m128i
    {.importc: "_mm_set_epi64", header: "emmintrin.h".}
    ## Exposes _mm_set_epi64 intrinsics

  proc mul_su32*(a: m64, b: m64): m64
    {.importc: "_mm_mul_su32", header: "emmintrin.h".}
    ## Exposes _mm_mul_su32 intrinsics

  proc sub_si64*(a: m64, b: m64): m64
    {.importc: "_mm_sub_si64", header: "emmintrin.h".}
    ## Exposes _mm_sub_si64 intrinsics

  proc set1_epi64*(q: m64): m128i
    {.importc: "_mm_set1_epi64", header: "emmintrin.h".}
    ## Exposes _mm_set1_epi64 intrinsics

  proc setr_epi64*(q0: m64, q1: m64): m128i
    {.importc: "_mm_setr_epi64", header: "emmintrin.h".}
    ## Exposes _mm_setr_epi64 intrinsics

  proc movepi64_pi64*(a: m128i): m64
    {.importc: "_mm_movepi64_pi64", header: "emmintrin.h".}
    ## Exposes _mm_movepi64_pi64 intrinsics

  proc movpi64_epi64*(a: m64): m128i
    {.importc: "_mm_movpi64_epi64", header: "emmintrin.h".}
    ## Exposes _mm_movpi64_epi64 intrinsics

# Assert we generate proper C code
when isMainModule:
  var myint32 : int32 = 2;
  var mym128 = set1_ps(1.0)
  var mym128i = setr_epi32(1,2,3,4)
  var mym128d = set1_pd(1.0)
  var myfloat64 : float64 = 1.0
  var argint8 : int8 = 1;
  var argint16 : int16 = 2;
  var argint64 : int64 = 1
  var argm128 = set1_ps(1.0)
  var argm128i = setr_epi32(1,2,3,4)
  var argm128d = set1_pd(1.0)
  var argfloat64 : float64 = 1.0
  var argptrint8 = addr(argint8)
  var argptrint32 : ptr int32 = cast[ptr int32](addr(argm128i))
  var argptrint64 : ptr int64 = cast[ptr int64](addr(argm128i))
  var argptrfloat64 : ptr float64 = cast[ptr float64](addr(argm128d))
  var argptrm128i : ptr m128i = addr(argm128i)
  when not vcc64Bits:
    var mym64 = set1_pi32(1)
    var argm64 = set1_pi32(1)
    mym64 = mul_su32(argm64, argm64)
    mym64 = add_si64(argm64, argm64)
    mym64 = cvtpd_pi32(argm128d)
    mym64 = cvttpd_pi32(argm128d)
    mym128d = cvtpi32_pd(argm64)
    mym64 = sub_si64(argm64, argm64)
    mym128i = set_epi64(argm64, argm64)
    mym128i = set1_epi64(argm64)
    mym128i = setr_epi64(argm64, argm64)
    mym64 = movepi64_pi64(argm128i)
    mym128i = movpi64_epi64(argm64)
  mym128d = add_sd(argm128d, argm128d)
  mym128d = add_pd(argm128d, argm128d)
  mym128d = sub_sd(argm128d, argm128d)
  mym128d = sub_pd(argm128d, argm128d)
  mym128d = mul_sd(argm128d, argm128d)
  mym128d = mul_pd(argm128d, argm128d)
  mym128d = div_sd(argm128d, argm128d)
  mym128d = div_pd(argm128d, argm128d)
  mym128d = sqrt_sd(argm128d, argm128d)
  mym128d = sqrt_pd(argm128d)
  mym128d = min_sd(argm128d, argm128d)
  mym128d = min_pd(argm128d, argm128d)
  mym128d = max_sd(argm128d, argm128d)
  mym128d = max_pd(argm128d, argm128d)
  mym128d = and_pd(argm128d, argm128d)
  mym128d = andnot_pd(argm128d, argm128d)
  mym128d = or_pd(argm128d, argm128d)
  mym128d = xor_pd(argm128d, argm128d)
  mym128d = cmpeq_pd(argm128d, argm128d)
  mym128d = cmplt_pd(argm128d, argm128d)
  mym128d = cmple_pd(argm128d, argm128d)
  mym128d = cmpgt_pd(argm128d, argm128d)
  mym128d = cmpge_pd(argm128d, argm128d)
  mym128d = cmpord_pd(argm128d, argm128d)
  mym128d = cmpunord_pd(argm128d, argm128d)
  mym128d = cmpneq_pd(argm128d, argm128d)
  mym128d = cmpnlt_pd(argm128d, argm128d)
  mym128d = cmpnle_pd(argm128d, argm128d)
  mym128d = cmpngt_pd(argm128d, argm128d)
  mym128d = cmpnge_pd(argm128d, argm128d)
  mym128d = cmpeq_sd(argm128d, argm128d)
  mym128d = cmplt_sd(argm128d, argm128d)
  mym128d = cmple_sd(argm128d, argm128d)
  mym128d = cmpgt_sd(argm128d, argm128d)
  mym128d = cmpge_sd(argm128d, argm128d)
  mym128d = cmpord_sd(argm128d, argm128d)
  mym128d = cmpunord_sd(argm128d, argm128d)
  mym128d = cmpneq_sd(argm128d, argm128d)
  mym128d = cmpnlt_sd(argm128d, argm128d)
  mym128d = cmpnle_sd(argm128d, argm128d)
  mym128d = cmpngt_sd(argm128d, argm128d)
  mym128d = cmpnge_sd(argm128d, argm128d)
  myint32 = comieq_sd(argm128d, argm128d)
  myint32 = comilt_sd(argm128d, argm128d)
  myint32 = comile_sd(argm128d, argm128d)
  myint32 = comigt_sd(argm128d, argm128d)
  myint32 = comige_sd(argm128d, argm128d)
  myint32 = comineq_sd(argm128d, argm128d)
  myint32 = ucomieq_sd(argm128d, argm128d)
  myint32 = ucomilt_sd(argm128d, argm128d)
  myint32 = ucomile_sd(argm128d, argm128d)
  myint32 = ucomigt_sd(argm128d, argm128d)
  myint32 = ucomige_sd(argm128d, argm128d)
  myint32 = ucomineq_sd(argm128d, argm128d)
  mym128 = cvtpd_ps(argm128d)
  mym128d = cvtps_pd(argm128)
  mym128d = cvtepi32_pd(argm128i)
  mym128i = cvtpd_epi32(argm128d)
  myint32 = cvtsd_si32(argm128d)
  mym128 = cvtsd_ss(argm128, argm128d)
  mym128d = cvtsi32_sd(argm128d, 1)
  mym128d = cvtss_sd(argm128d, argm128)
  mym128i = cvttpd_epi32(argm128d)
  myint32 = cvttsd_si32(argm128d)
  myfloat64 = cvtsd_f64(argm128d)
  mym128d = load_pd(argptrfloat64)
  mym128d = load1_pd(argptrfloat64)
  mym128d = loadr_pd(argptrfloat64)
  mym128d = loadu_pd(argptrfloat64)
  mym128d = load_sd(argptrfloat64)
  mym128d = loadh_pd(argm128d, argptrfloat64)
  mym128d = loadl_pd(argm128d, argptrfloat64)
  mym128d = set_sd(argfloat64)
  mym128d = set1_pd(argfloat64)
  mym128d = set_pd(argfloat64, argfloat64)
  mym128d = setr_pd(argfloat64, argfloat64)
  mym128d = setzero_pd()
  mym128d = move_sd(argm128d, argm128d)
  store_sd(argptrfloat64, argm128d)
  store1_pd(argptrfloat64, argm128d)
  store_pd(argptrfloat64, argm128d)
  storeu_pd(argptrfloat64, argm128d)
  storer_pd(argptrfloat64, argm128d)
  storeh_pd(argptrfloat64, argm128d)
  storel_pd(argptrfloat64, argm128d)
  mym128i = add_epi8(argm128i, argm128i)
  mym128i = add_epi16(argm128i, argm128i)
  mym128i = add_epi32(argm128i, argm128i)
  mym128i = add_epi64(argm128i, argm128i)
  mym128i = adds_epi8(argm128i, argm128i)
  mym128i = adds_epi16(argm128i, argm128i)
  mym128i = adds_epu8(argm128i, argm128i)
  mym128i = adds_epu16(argm128i, argm128i)
  mym128i = avg_epu8(argm128i, argm128i)
  mym128i = avg_epu16(argm128i, argm128i)
  mym128i = madd_epi16(argm128i, argm128i)
  mym128i = max_epi16(argm128i, argm128i)
  mym128i = max_epu8(argm128i, argm128i)
  mym128i = min_epi16(argm128i, argm128i)
  mym128i = min_epu8(argm128i, argm128i)
  mym128i = mulhi_epi16(argm128i, argm128i)
  mym128i = mulhi_epu16(argm128i, argm128i)
  mym128i = mullo_epi16(argm128i, argm128i)
  mym128i = mul_epu32(argm128i, argm128i)
  mym128i = sad_epu8(argm128i, argm128i)
  mym128i = sub_epi8(argm128i, argm128i)
  mym128i = sub_epi16(argm128i, argm128i)
  mym128i = sub_epi32(argm128i, argm128i)
  mym128i = sub_epi64(argm128i, argm128i)
  mym128i = subs_epi8(argm128i, argm128i)
  mym128i = subs_epi16(argm128i, argm128i)
  mym128i = subs_epu8(argm128i, argm128i)
  mym128i = subs_epu16(argm128i, argm128i)
  mym128i = and_si128(argm128i, argm128i)
  mym128i = andnot_si128(argm128i, argm128i)
  mym128i = or_si128(argm128i, argm128i)
  mym128i = xor_si128(argm128i, argm128i)
  mym128i = slli_epi16(argm128i, 1)
  mym128i = sll_epi16(argm128i, argm128i)
  mym128i = slli_epi32(argm128i, 1)
  mym128i = sll_epi32(argm128i, argm128i)
  mym128i = slli_epi64(argm128i, 1)
  mym128i = sll_epi64(argm128i, argm128i)
  mym128i = srai_epi16(argm128i, 1)
  mym128i = sra_epi16(argm128i, argm128i)
  mym128i = srai_epi32(argm128i, 1)
  mym128i = sra_epi32(argm128i, argm128i)
  mym128i = srli_epi16(argm128i, 1)
  mym128i = srl_epi16(argm128i, argm128i)
  mym128i = srli_epi32(argm128i, 1)
  mym128i = srl_epi32(argm128i, argm128i)
  mym128i = srli_epi64(argm128i, 1)
  mym128i = srl_epi64(argm128i, argm128i)
  mym128i = cmpeq_epi8(argm128i, argm128i)
  mym128i = cmpeq_epi16(argm128i, argm128i)
  mym128i = cmpeq_epi32(argm128i, argm128i)
  mym128i = cmpgt_epi8(argm128i, argm128i)
  mym128i = cmpgt_epi16(argm128i, argm128i)
  mym128i = cmpgt_epi32(argm128i, argm128i)
  mym128i = cmplt_epi8(argm128i, argm128i)
  mym128i = cmplt_epi16(argm128i, argm128i)
  mym128i = cmplt_epi32(argm128i, argm128i)
  when defined(x86_64):
    mym128d = cvtsi64_sd(argm128d, argint64)
    mym128i = cvtsi64_si128(argint64)
  mym128 = cvtepi32_ps(argm128i)
  mym128i = cvtps_epi32(argm128)
  mym128i = cvttps_epi32(argm128)
  mym128i = cvtsi32_si128(1)
  myint32 = cvtsi128_si32(argm128i)
  mym128i = load_si128(argptrm128i)
  mym128i = loadu_si128(argptrm128i)
  mym128i = loadl_epi64(argptrm128i)
  when defined(x86_64):
    stream_si64(argptrint64, argint64)
  mym128i = set_epi32(1, 1, 1, 1)
  mym128i = set_epi16(argint16, argint16, argint16, argint16, argint16, argint16, argint16, argint16)
  mym128i = set_epi8(argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8)
  mym128i = set1_epi32(1)
  mym128i = set1_epi16(argint16)
  mym128i = set1_epi8(argint8)
  mym128i = setr_epi32(1, 1, 1, 1)
  mym128i = setr_epi16(argint16, argint16, argint16, argint16, argint16, argint16, argint16, argint16)
  mym128i = setr_epi8(argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8, argint8)
  mym128i = setzero_si128()
  store_si128(argptrm128i, argm128i)
  storeu_si128(argptrm128i, argm128i)
  maskmoveu_si128(argm128i, argm128i, argptrint8)
  storel_epi64(argptrm128i, argm128i)
  stream_pd(argptrfloat64, argm128d)
  stream_si128(argptrm128i, argm128i)
  stream_si32(argptrint32, 1)
  clflush(argptrint8)
  lfence()
  mfence()
  mym128i = packs_epi16(argm128i, argm128i)
  mym128i = packs_epi32(argm128i, argm128i)
  mym128i = packus_epi16(argm128i, argm128i)
  myint32 = extract_epi16(argm128i, 1)
  mym128i = insert_epi16(argm128i, 1, 1)
  myint32 = movemask_epi8(argm128i)
  mym128i = unpackhi_epi8(argm128i, argm128i)
  mym128i = unpackhi_epi16(argm128i, argm128i)
  mym128i = unpackhi_epi32(argm128i, argm128i)
  mym128i = unpackhi_epi64(argm128i, argm128i)
  mym128i = unpacklo_epi8(argm128i, argm128i)
  mym128i = unpacklo_epi16(argm128i, argm128i)
  mym128i = unpacklo_epi32(argm128i, argm128i)
  mym128i = unpacklo_epi64(argm128i, argm128i)
  mym128i = move_epi64(argm128i)
  mym128d = unpackhi_pd(argm128d, argm128d)
  mym128d = unpacklo_pd(argm128d, argm128d)
  myint32 = movemask_pd(argm128d)
  mym128 = castpd_ps(argm128d)
  mym128i = castpd_si128(argm128d)
  mym128d = castps_pd(argm128)
  mym128i = castps_si128(argm128)
  mym128 = castsi128_ps(argm128i)
  mym128d = castsi128_pd(argm128i)
  pause()
  mym128i = slli_si128(argm128i, 1)
  mym128i = srli_si128(argm128i, 1)
  mym128i = shuffle_epi32(argm128i, 1)
  mym128i = shufflelo_epi16(argm128i, 1)
  mym128i = shufflehi_epi16(argm128i, 1)
  mym128d = shuffle_pd(argm128d, argm128d, 1)

