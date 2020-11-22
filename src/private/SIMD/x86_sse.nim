#
#
#          Nimrod's x86 sse intrinsics
#        (c) Copyright 2014 Ben Segovia
#
#    See the file copying.txt, included in this
#    distribution, for details about the copyright.
#

const someGcc = defined(gcc) or defined(llvm_gcc) or defined(clang)
when someGcc:
  {.passC: "-msse".}
  {.passL: "-msse".}

# MSVC does not support MMX on 64 bits target
const vcc64Bits = defined(vcc) and defined(x86_64)

import x86_mmx
type m128* {.importc: "__m128", header: "xmmintrin.h".} = object

proc add_ss*(a: m128, b: m128): m128
  {.importc: "_mm_add_ss", header: "xmmintrin.h".}
  ## Exposes _mm_add_ss intrinsics

proc add_ps*(a: m128, b: m128): m128
  {.importc: "_mm_add_ps", header: "xmmintrin.h".}
  ## Exposes _mm_add_ps intrinsics

proc sub_ss*(a: m128, b: m128): m128
  {.importc: "_mm_sub_ss", header: "xmmintrin.h".}
  ## Exposes _mm_sub_ss intrinsics

proc sub_ps*(a: m128, b: m128): m128
  {.importc: "_mm_sub_ps", header: "xmmintrin.h".}
  ## Exposes _mm_sub_ps intrinsics

proc mul_ss*(a: m128, b: m128): m128
  {.importc: "_mm_mul_ss", header: "xmmintrin.h".}
  ## Exposes _mm_mul_ss intrinsics

proc mul_ps*(a: m128, b: m128): m128
  {.importc: "_mm_mul_ps", header: "xmmintrin.h".}
  ## Exposes _mm_mul_ps intrinsics

proc div_ss*(a: m128, b: m128): m128
  {.importc: "_mm_div_ss", header: "xmmintrin.h".}
  ## Exposes _mm_div_ss intrinsics

proc div_ps*(a: m128, b: m128): m128
  {.importc: "_mm_div_ps", header: "xmmintrin.h".}
  ## Exposes _mm_div_ps intrinsics

proc sqrt_ss*(a: m128): m128
  {.importc: "_mm_sqrt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_sqrt_ss intrinsics

proc sqrt_ps*(a: m128): m128
  {.importc: "_mm_sqrt_ps", header: "xmmintrin.h".}
  ## Exposes _mm_sqrt_ps intrinsics

proc rcp_ss*(a: m128): m128
  {.importc: "_mm_rcp_ss", header: "xmmintrin.h".}
  ## Exposes _mm_rcp_ss intrinsics

proc rcp_ps*(a: m128): m128
  {.importc: "_mm_rcp_ps", header: "xmmintrin.h".}
  ## Exposes _mm_rcp_ps intrinsics

proc rsqrt_ss*(a: m128): m128
  {.importc: "_mm_rsqrt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_rsqrt_ss intrinsics

proc rsqrt_ps*(a: m128): m128
  {.importc: "_mm_rsqrt_ps", header: "xmmintrin.h".}
  ## Exposes _mm_rsqrt_ps intrinsics

proc min_ss*(a: m128, b: m128): m128
  {.importc: "_mm_min_ss", header: "xmmintrin.h".}
  ## Exposes _mm_min_ss intrinsics

proc min_ps*(a: m128, b: m128): m128
  {.importc: "_mm_min_ps", header: "xmmintrin.h".}
  ## Exposes _mm_min_ps intrinsics

proc max_ss*(a: m128, b: m128): m128
  {.importc: "_mm_max_ss", header: "xmmintrin.h".}
  ## Exposes _mm_max_ss intrinsics

proc max_ps*(a: m128, b: m128): m128
  {.importc: "_mm_max_ps", header: "xmmintrin.h".}
  ## Exposes _mm_max_ps intrinsics

proc and_ps*(a: m128, b: m128): m128
  {.importc: "_mm_and_ps", header: "xmmintrin.h".}
  ## Exposes _mm_and_ps intrinsics

proc andnot_ps*(a: m128, b: m128): m128
  {.importc: "_mm_andnot_ps", header: "xmmintrin.h".}
  ## Exposes _mm_andnot_ps intrinsics

proc or_ps*(a: m128, b: m128): m128
  {.importc: "_mm_or_ps", header: "xmmintrin.h".}
  ## Exposes _mm_or_ps intrinsics

proc xor_ps*(a: m128, b: m128): m128
  {.importc: "_mm_xor_ps", header: "xmmintrin.h".}
  ## Exposes _mm_xor_ps intrinsics

proc cmpeq_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpeq_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpeq_ss intrinsics

proc cmpeq_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpeq_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpeq_ps intrinsics

proc cmplt_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmplt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmplt_ss intrinsics

proc cmplt_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmplt_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmplt_ps intrinsics

proc cmple_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmple_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmple_ss intrinsics

proc cmple_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmple_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmple_ps intrinsics

proc cmpgt_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpgt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpgt_ss intrinsics

proc cmpgt_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpgt_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpgt_ps intrinsics

proc cmpge_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpge_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpge_ss intrinsics

proc cmpge_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpge_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpge_ps intrinsics

proc cmpneq_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpneq_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpneq_ss intrinsics

proc cmpneq_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpneq_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpneq_ps intrinsics

proc cmpnlt_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpnlt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpnlt_ss intrinsics

proc cmpnlt_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpnlt_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpnlt_ps intrinsics

proc cmpnle_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpnle_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpnle_ss intrinsics

proc cmpnle_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpnle_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpnle_ps intrinsics

proc cmpngt_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpngt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpngt_ss intrinsics

proc cmpngt_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpngt_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpngt_ps intrinsics

proc cmpnge_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpnge_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpnge_ss intrinsics

proc cmpnge_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpnge_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpnge_ps intrinsics

proc cmpord_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpord_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpord_ss intrinsics

proc cmpord_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpord_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpord_ps intrinsics

proc cmpunord_ss*(a: m128, b: m128): m128
  {.importc: "_mm_cmpunord_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cmpunord_ss intrinsics

proc cmpunord_ps*(a: m128, b: m128): m128
  {.importc: "_mm_cmpunord_ps", header: "xmmintrin.h".}
  ## Exposes _mm_cmpunord_ps intrinsics

proc comieq_ss*(a: m128, b: m128): int32
  {.importc: "_mm_comieq_ss", header: "xmmintrin.h".}
  ## Exposes _mm_comieq_ss intrinsics

proc comilt_ss*(a: m128, b: m128): int32
  {.importc: "_mm_comilt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_comilt_ss intrinsics

proc comile_ss*(a: m128, b: m128): int32
  {.importc: "_mm_comile_ss", header: "xmmintrin.h".}
  ## Exposes _mm_comile_ss intrinsics

proc comigt_ss*(a: m128, b: m128): int32
  {.importc: "_mm_comigt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_comigt_ss intrinsics

proc comige_ss*(a: m128, b: m128): int32
  {.importc: "_mm_comige_ss", header: "xmmintrin.h".}
  ## Exposes _mm_comige_ss intrinsics

proc comineq_ss*(a: m128, b: m128): int32
  {.importc: "_mm_comineq_ss", header: "xmmintrin.h".}
  ## Exposes _mm_comineq_ss intrinsics

proc ucomieq_ss*(a: m128, b: m128): int32
  {.importc: "_mm_ucomieq_ss", header: "xmmintrin.h".}
  ## Exposes _mm_ucomieq_ss intrinsics

proc ucomilt_ss*(a: m128, b: m128): int32
  {.importc: "_mm_ucomilt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_ucomilt_ss intrinsics

proc ucomile_ss*(a: m128, b: m128): int32
  {.importc: "_mm_ucomile_ss", header: "xmmintrin.h".}
  ## Exposes _mm_ucomile_ss intrinsics

proc ucomigt_ss*(a: m128, b: m128): int32
  {.importc: "_mm_ucomigt_ss", header: "xmmintrin.h".}
  ## Exposes _mm_ucomigt_ss intrinsics

proc ucomige_ss*(a: m128, b: m128): int32
  {.importc: "_mm_ucomige_ss", header: "xmmintrin.h".}
  ## Exposes _mm_ucomige_ss intrinsics

proc ucomineq_ss*(a: m128, b: m128): int32
  {.importc: "_mm_ucomineq_ss", header: "xmmintrin.h".}
  ## Exposes _mm_ucomineq_ss intrinsics

proc cvtss_si32*(a: m128): int32
  {.importc: "_mm_cvtss_si32", header: "xmmintrin.h".}
  ## Exposes _mm_cvtss_si32 intrinsics

proc cvt_ss2si*(a: m128): int32
  {.importc: "_mm_cvt_ss2si", header: "xmmintrin.h".}
  ## Exposes _mm_cvt_ss2si intrinsics

proc cvttss_si32*(a: m128): int32
  {.importc: "_mm_cvttss_si32", header: "xmmintrin.h".}
  ## Exposes _mm_cvttss_si32 intrinsics

proc cvtt_ss2si*(a: m128): int32
  {.importc: "_mm_cvtt_ss2si", header: "xmmintrin.h".}
  ## Exposes _mm_cvtt_ss2si intrinsics

when not vcc64Bits:
  proc cvtps_pi32*(a: m128): m64
    {.importc: "_mm_cvtps_pi32", header: "xmmintrin.h".}
    ## Exposes _mm_cvtps_pi32 intrinsics

  proc cvt_ps2pi*(a: m128): m64
    {.importc: "_mm_cvt_ps2pi", header: "xmmintrin.h".}
    ## Exposes _mm_cvt_ps2pi intrinsics

  proc cvttps_pi32*(a: m128): m64
    {.importc: "_mm_cvttps_pi32", header: "xmmintrin.h".}
    ## Exposes _mm_cvttps_pi32 intrinsics

  proc cvtt_ps2pi*(a: m128): m64
    {.importc: "_mm_cvtt_ps2pi", header: "xmmintrin.h".}
    ## Exposes _mm_cvtt_ps2pi intrinsics

  proc stream_pi*(p: ptr m64, a: m64): void
    {.importc: "_mm_stream_pi", header: "xmmintrin.h".}
    ## Exposes _mm_stream_pi intrinsics

  proc cvtpi16_ps*(a: m64): m128
    {.importc: "_mm_cvtpi16_ps", header: "xmmintrin.h".}
    ## Exposes _mm_cvtpi16_ps intrinsics

  proc cvtpu16_ps*(a: m64): m128
    {.importc: "_mm_cvtpu16_ps", header: "xmmintrin.h".}
    ## Exposes _mm_cvtpu16_ps intrinsics

  proc cvtpi8_ps*(a: m64): m128
    {.importc: "_mm_cvtpi8_ps", header: "xmmintrin.h".}
    ## Exposes _mm_cvtpi8_ps intrinsics

  proc cvtpu8_ps*(a: m64): m128
    {.importc: "_mm_cvtpu8_ps", header: "xmmintrin.h".}
    ## Exposes _mm_cvtpu8_ps intrinsics

  proc cvtpi32x2_ps*(a: m64, b: m64): m128
    {.importc: "_mm_cvtpi32x2_ps", header: "xmmintrin.h".}
    ## Exposes _mm_cvtpi32x2_ps intrinsics

  proc cvtps_pi16*(a: m128): m64
    {.importc: "_mm_cvtps_pi16", header: "xmmintrin.h".}
    ## Exposes _mm_cvtps_pi16 intrinsics

  proc cvtps_pi8*(a: m128): m64
    {.importc: "_mm_cvtps_pi8", header: "xmmintrin.h".}
    ## Exposes _mm_cvtps_pi8 intrinsics

  proc cvtpi32_ps*(a: m128, b: m64): m128
    {.importc: "_mm_cvtpi32_ps", header: "xmmintrin.h".}
    ## Exposes _mm_cvtpi32_ps intrinsics

  proc cvt_pi2ps*(a: m128, b: m64): m128
    {.importc: "_mm_cvt_pi2ps", header: "xmmintrin.h".}
    ## Exposes _mm_cvt_pi2ps intrinsics

  proc loadh_pi*(a: m128,  p: ptr m64): m128
    {.importc: "_mm_loadh_pi", header: "xmmintrin.h".}
    ## Exposes _mm_loadh_pi intrinsics

  proc loadl_pi*(a: m128,  p: ptr m64): m128
    {.importc: "_mm_loadl_pi", header: "xmmintrin.h".}
    ## Exposes _mm_loadl_pi intrinsics

  proc storeh_pi*(p: ptr m64, a: m128): void
    {.importc: "_mm_storeh_pi", header: "xmmintrin.h".}
    ## Exposes _mm_storeh_pi intrinsics

  proc storel_pi*(p: ptr m64, a: m128): void
    {.importc: "_mm_storel_pi", header: "xmmintrin.h".}
    ## Exposes _mm_storel_pi intrinsics

  proc extract_pi16*(a: m64, n: int32): int32
    {.importc: "_mm_extract_pi16", header: "xmmintrin.h".}
    ## Exposes _mm_extract_pi16 intrinsics

  proc insert_pi16*(a: m64, d: int32, n: int32): m64
    {.importc: "_mm_insert_pi16", header: "xmmintrin.h".}
    ## Exposes _mm_insert_pi16 intrinsics

  proc max_pi16*(a: m64, b: m64): m64
    {.importc: "_mm_max_pi16", header: "xmmintrin.h".}
    ## Exposes _mm_max_pi16 intrinsics

  proc max_pu8*(a: m64, b: m64): m64
    {.importc: "_mm_max_pu8", header: "xmmintrin.h".}
    ## Exposes _mm_max_pu8 intrinsics

  proc min_pi16*(a: m64, b: m64): m64
    {.importc: "_mm_min_pi16", header: "xmmintrin.h".}
    ## Exposes _mm_min_pi16 intrinsics

  proc min_pu8*(a: m64, b: m64): m64
    {.importc: "_mm_min_pu8", header: "xmmintrin.h".}
    ## Exposes _mm_min_pu8 intrinsics

  proc movemask_pi8*(a: m64): int32
    {.importc: "_mm_movemask_pi8", header: "xmmintrin.h".}
    ## Exposes _mm_movemask_pi8 intrinsics

  proc mulhi_pu16*(a: m64, b: m64): m64
    {.importc: "_mm_mulhi_pu16", header: "xmmintrin.h".}
    ## Exposes _mm_mulhi_pu16 intrinsics

  proc maskmove_si64*(d: m64, n: m64, p: ptr int8): void
    {.importc: "_mm_maskmove_si64", header: "xmmintrin.h".}
    ## Exposes _mm_maskmove_si64 intrinsics

  proc avg_pu8*(a: m64, b: m64): m64
    {.importc: "_mm_avg_pu8", header: "xmmintrin.h".}
    ## Exposes _mm_avg_pu8 intrinsics

  proc avg_pu16*(a: m64, b: m64): m64
    {.importc: "_mm_avg_pu16", header: "xmmintrin.h".}
    ## Exposes _mm_avg_pu16 intrinsics

  proc sad_pu8*(a: m64, b: m64): m64
    {.importc: "_mm_sad_pu8", header: "xmmintrin.h".}
    ## Exposes _mm_sad_pu8 intrinsics

proc cvtsi32_ss*(a: m128, b: int32): m128
  {.importc: "_mm_cvtsi32_ss", header: "xmmintrin.h".}
  ## Exposes _mm_cvtsi32_ss intrinsics

proc cvt_si2ss*(a: m128, b: int32): m128
  {.importc: "_mm_cvt_si2ss", header: "xmmintrin.h".}
  ## Exposes _mm_cvt_si2ss intrinsics

when defined(x86_64):
  proc cvtsi64_ss*(a: m128, b: int64): m128
    {.importc: "_mm_cvtsi64_ss", header: "xmmintrin.h".}
    ## Exposes _mm_cvtsi64_ss intrinsics

proc cvtss_f32*(a: m128): float32
  {.importc: "_mm_cvtss_f32", header: "xmmintrin.h".}
  ## Exposes _mm_cvtss_f32 intrinsics

proc load_ss*( p: ptr float32): m128
  {.importc: "_mm_load_ss", header: "xmmintrin.h".}
  ## Exposes _mm_load_ss intrinsics

proc load1_ps*( p: ptr float32): m128
  {.importc: "_mm_load1_ps", header: "xmmintrin.h".}
  ## Exposes _mm_load1_ps intrinsics

proc load_ps*( p: ptr float32): m128
  {.importc: "_mm_load_ps", header: "xmmintrin.h".}
  ## Exposes _mm_load_ps intrinsics

proc loadu_ps*( p: ptr float32): m128
  {.importc: "_mm_loadu_ps", header: "xmmintrin.h".}
  ## Exposes _mm_loadu_ps intrinsics

proc loadr_ps*( p: ptr float32): m128
  {.importc: "_mm_loadr_ps", header: "xmmintrin.h".}
  ## Exposes _mm_loadr_ps intrinsics

proc set_ss*(w: float32): m128
  {.importc: "_mm_set_ss", header: "xmmintrin.h".}
  ## Exposes _mm_set_ss intrinsics

proc set1_ps*(w: float32): m128
  {.importc: "_mm_set1_ps", header: "xmmintrin.h".}
  ## Exposes _mm_set1_ps intrinsics

proc set_ps1*(w: float32): m128
  {.importc: "_mm_set_ps1", header: "xmmintrin.h".}
  ## Exposes _mm_set_ps1 intrinsics

proc set_ps*(z: float32, y: float32, x: float32, w: float32): m128
  {.importc: "_mm_set_ps", header: "xmmintrin.h".}
  ## Exposes _mm_set_ps intrinsics

proc setr_ps*(z: float32, y: float32, x: float32, w: float32): m128
  {.importc: "_mm_setr_ps", header: "xmmintrin.h".}
  ## Exposes _mm_setr_ps intrinsics

proc setzero_ps*(): m128
  {.importc: "_mm_setzero_ps", header: "xmmintrin.h".}
  ## Exposes _mm_setzero_ps intrinsics

proc store_ss*(p: ptr float32, a: m128): void
  {.importc: "_mm_store_ss", header: "xmmintrin.h".}
  ## Exposes _mm_store_ss intrinsics

proc storeu_ps*(p: ptr float32, a: m128): void
  {.importc: "_mm_storeu_ps", header: "xmmintrin.h".}
  ## Exposes _mm_storeu_ps intrinsics

proc store1_ps*(p: ptr float32, a: m128): void
  {.importc: "_mm_store1_ps", header: "xmmintrin.h".}
  ## Exposes _mm_store1_ps intrinsics

proc store_ps1*(p: ptr float32, a: m128): void
  {.importc: "_mm_store_ps1", header: "xmmintrin.h".}
  ## Exposes _mm_store_ps1 intrinsics

proc store_ps*(p: ptr float32, a: m128): void
  {.importc: "_mm_store_ps", header: "xmmintrin.h".}
  ## Exposes _mm_store_ps intrinsics

proc storer_ps*(p: ptr float32, a: m128): void
  {.importc: "_mm_storer_ps", header: "xmmintrin.h".}
  ## Exposes _mm_storer_ps intrinsics

proc stream_ps*(p: ptr float32, a: m128): void
  {.importc: "_mm_stream_ps", header: "xmmintrin.h".}
  ## Exposes _mm_stream_ps intrinsics

proc sfence*(): void
  {.importc: "_mm_sfence", header: "xmmintrin.h".}
  ## Exposes _mm_sfence intrinsics

proc getcsr*(): int32
  {.importc: "_mm_getcsr", header: "xmmintrin.h".}
  ## Exposes _mm_getcsr intrinsics

proc setcsr*(i: int32): void
  {.importc: "_mm_setcsr", header: "xmmintrin.h".}
  ## Exposes _mm_setcsr intrinsics

proc unpackhi_ps*(a: m128, b: m128): m128
  {.importc: "_mm_unpackhi_ps", header: "xmmintrin.h".}
  ## Exposes _mm_unpackhi_ps intrinsics

proc unpacklo_ps*(a: m128, b: m128): m128
  {.importc: "_mm_unpacklo_ps", header: "xmmintrin.h".}
  ## Exposes _mm_unpacklo_ps intrinsics

proc move_ss*(a: m128, b: m128): m128
  {.importc: "_mm_move_ss", header: "xmmintrin.h".}
  ## Exposes _mm_move_ss intrinsics

proc movehl_ps*(a: m128, b: m128): m128
  {.importc: "_mm_movehl_ps", header: "xmmintrin.h".}
  ## Exposes _mm_movehl_ps intrinsics

proc movelh_ps*(a: m128, b: m128): m128
  {.importc: "_mm_movelh_ps", header: "xmmintrin.h".}
  ## Exposes _mm_movelh_ps intrinsics

proc movemask_ps*(a: m128): int32
  {.importc: "_mm_movemask_ps", header: "xmmintrin.h".}
  ## Exposes _mm_movemask_ps intrinsics

# Export all xmmintrin.h constants
const EXCEPT_INVALID* = 0x0001
const EXCEPT_DENORM* = 0x0002
const EXCEPT_DIV_ZERO* = 0x0004
const EXCEPT_OVERFLOW* = 0x0008
const EXCEPT_UNDERFLOW* = 0x0010
const EXCEPT_INEXACT* = 0x0020
const EXCEPT_MASK* = 0x003f
const MASK_INVALID* = 0x0080
const MASK_DENORM* = 0x0100
const MASK_DIV_ZERO* = 0x0200
const MASK_OVERFLOW* = 0x0400
const MASK_UNDERFLOW* = 0x0800
const MASK_INEXACT* = 0x1000
const MASK_MASK* = 0x1f80
const ROUND_NEAREST* = 0x0000
const ROUND_DOWN* = 0x2000
const ROUND_UP* = 0x4000
const ROUND_TOWARD_ZERO* = 0x6000
const ROUND_MASK* = 0x6000
const FLUSH_ZERO_MASK* = 0x8000
const FLUSH_ZERO_ON* = 0x8000
const FLUSH_ZERO_OFF* = 0x0000

# Export all xmmintrin.h macros
proc get_exception_mask*() : int32 {.inline.} =
  getcsr() and MASK_MASK

proc get_exception_state*() : int32 {.inline.} =
  getcsr() and EXCEPT_MASK

proc get_flush_zero_mode*() : int32 {.inline.} =
  getcsr() and FLUSH_ZERO_MASK

proc get_rounding_mode*() : int32 {.inline.} =
  getcsr() and ROUND_MASK

proc set_exception_mask*(x: int32) {.inline.} =
  setcsr((getcsr() and not MASK_MASK) or x)

proc set_exception_state*(x: int32) {.inline.} =
  setcsr((getcsr() and not EXCEPT_MASK) or x)

proc set_flush_zero_mode*(x: int32) {.inline.} =
  setcsr((getcsr() and not FLUSH_ZERO_MASK) or x)

proc set_rounding_mode*(x: int32) {.inline.} =
  setcsr((getcsr() and not ROUND_MASK) or x)

# Assert we generate proper C code
when isMainModule:
  var myint32 : int32 = 1;
  var mym128 = set1_ps(1.0)
  var myfloat32 : float32 = 1.0
  var argint8 : int8 = 1;
  var argm128 = set1_ps(1.0)
  when defined(x86_64):
    var argint64 : int64 = 1
  var argfloat32 : float32 = 1.0
  var argptrint8 = addr(argint8)
  var argptrfloat32 : ptr float32 = cast[ptr float32](addr(argm128))
  when not vcc64Bits:
    var mym64 = set1_pi32(1)
    var argm64 = set1_pi32(1)
    var argptrm64 = addr(argm64)
    mym64 = cvtps_pi32(argm128)
    mym64 = cvt_ps2pi(argm128)
    mym64 = cvttps_pi32(argm128)
    mym64 = cvtt_ps2pi(argm128)
    mym128 = cvtpi32_ps(argm128, argm64)
    mym128 = cvt_pi2ps(argm128, argm64)
    mym128 = loadh_pi(argm128,  argptrm64)
    mym128 = loadl_pi(argm128,  argptrm64)
    storeh_pi(argptrm64, argm128)
    storel_pi(argptrm64, argm128)
    myint32 = extract_pi16(argm64, 1)
    mym64 = insert_pi16(argm64, 1, 1)
    mym64 = max_pi16(argm64, argm64)
    mym64 = max_pu8(argm64, argm64)
    mym64 = min_pi16(argm64, argm64)
    mym64 = min_pu8(argm64, argm64)
    myint32 = movemask_pi8(argm64)
    mym64 = mulhi_pu16(argm64, argm64)
    maskmove_si64(argm64, argm64, argptrint8)
    mym64 = avg_pu8(argm64, argm64)
    mym64 = avg_pu16(argm64, argm64)
    mym64 = sad_pu8(argm64, argm64)
    stream_pi(argptrm64, argm64)
    mym128 = cvtpi16_ps(argm64)
    mym128 = cvtpu16_ps(argm64)
    mym128 = cvtpi8_ps(argm64)
    mym128 = cvtpu8_ps(argm64)
    mym128 = cvtpi32x2_ps(argm64, argm64)
    mym64 = cvtps_pi16(argm128)
    mym64 = cvtps_pi8(argm128)
  mym128 = add_ss(argm128, argm128)
  mym128 = add_ps(argm128, argm128)
  mym128 = sub_ss(argm128, argm128)
  mym128 = sub_ps(argm128, argm128)
  mym128 = mul_ss(argm128, argm128)
  mym128 = mul_ps(argm128, argm128)
  mym128 = div_ss(argm128, argm128)
  mym128 = div_ps(argm128, argm128)
  mym128 = sqrt_ss(argm128)
  mym128 = sqrt_ps(argm128)
  mym128 = rcp_ss(argm128)
  mym128 = rcp_ps(argm128)
  mym128 = rsqrt_ss(argm128)
  mym128 = rsqrt_ps(argm128)
  mym128 = min_ss(argm128, argm128)
  mym128 = min_ps(argm128, argm128)
  mym128 = max_ss(argm128, argm128)
  mym128 = max_ps(argm128, argm128)
  mym128 = and_ps(argm128, argm128)
  mym128 = andnot_ps(argm128, argm128)
  mym128 = or_ps(argm128, argm128)
  mym128 = xor_ps(argm128, argm128)
  mym128 = cmpeq_ss(argm128, argm128)
  mym128 = cmpeq_ps(argm128, argm128)
  mym128 = cmplt_ss(argm128, argm128)
  mym128 = cmplt_ps(argm128, argm128)
  mym128 = cmple_ss(argm128, argm128)
  mym128 = cmple_ps(argm128, argm128)
  mym128 = cmpgt_ss(argm128, argm128)
  mym128 = cmpgt_ps(argm128, argm128)
  mym128 = cmpge_ss(argm128, argm128)
  mym128 = cmpge_ps(argm128, argm128)
  mym128 = cmpneq_ss(argm128, argm128)
  mym128 = cmpneq_ps(argm128, argm128)
  mym128 = cmpnlt_ss(argm128, argm128)
  mym128 = cmpnlt_ps(argm128, argm128)
  mym128 = cmpnle_ss(argm128, argm128)
  mym128 = cmpnle_ps(argm128, argm128)
  mym128 = cmpngt_ss(argm128, argm128)
  mym128 = cmpngt_ps(argm128, argm128)
  mym128 = cmpnge_ss(argm128, argm128)
  mym128 = cmpnge_ps(argm128, argm128)
  mym128 = cmpord_ss(argm128, argm128)
  mym128 = cmpord_ps(argm128, argm128)
  mym128 = cmpunord_ss(argm128, argm128)
  mym128 = cmpunord_ps(argm128, argm128)
  myint32 = comieq_ss(argm128, argm128)
  myint32 = comilt_ss(argm128, argm128)
  myint32 = comile_ss(argm128, argm128)
  myint32 = comigt_ss(argm128, argm128)
  myint32 = comige_ss(argm128, argm128)
  myint32 = comineq_ss(argm128, argm128)
  myint32 = ucomieq_ss(argm128, argm128)
  myint32 = ucomilt_ss(argm128, argm128)
  myint32 = ucomile_ss(argm128, argm128)
  myint32 = ucomigt_ss(argm128, argm128)
  myint32 = ucomige_ss(argm128, argm128)
  myint32 = ucomineq_ss(argm128, argm128)
  myint32 = cvtss_si32(argm128)
  myint32 = cvt_ss2si(argm128)
  myint32 = cvttss_si32(argm128)
  myint32 = cvtt_ss2si(argm128)
  mym128 = cvtsi32_ss(argm128, 1)
  mym128 = cvt_si2ss(argm128, 1)
  when defined(x86_64):
    mym128 = cvtsi64_ss(argm128, argint64)
  myfloat32 = cvtss_f32(argm128)
  mym128 = load_ss( argptrfloat32)
  mym128 = load1_ps( argptrfloat32)
  mym128 = load_ps( argptrfloat32)
  mym128 = loadu_ps( argptrfloat32)
  mym128 = loadr_ps( argptrfloat32)
  mym128 = set_ss(argfloat32)
  mym128 = set1_ps(argfloat32)
  mym128 = set_ps1(argfloat32)
  mym128 = set_ps(argfloat32, argfloat32, argfloat32, argfloat32)
  mym128 = setr_ps(argfloat32, argfloat32, argfloat32, argfloat32)
  mym128 = setzero_ps()
  store_ss(argptrfloat32, argm128)
  storeu_ps(argptrfloat32, argm128)
  store1_ps(argptrfloat32, argm128)
  store_ps1(argptrfloat32, argm128)
  store_ps(argptrfloat32, argm128)
  storer_ps(argptrfloat32, argm128)
  stream_ps(argptrfloat32, argm128)
  sfence()
  myint32 = getcsr()
  setcsr(1)
  mym128 = unpackhi_ps(argm128, argm128)
  mym128 = unpacklo_ps(argm128, argm128)
  mym128 = move_ss(argm128, argm128)
  mym128 = movehl_ps(argm128, argm128)
  mym128 = movelh_ps(argm128, argm128)
  myint32 = movemask_ps(argm128)

