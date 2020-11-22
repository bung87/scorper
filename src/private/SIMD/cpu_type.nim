proc cpuidex*(cpuInfo:ptr int,function_id:cint,subfunction_id:cint)
  {.importc:"__cpuidex", header:"intrin.h"}

proc c_xgetbv*(xcr:cuint) : uint64
  {.importc:"_xgetbv", header:"immintrin.h"}

when defined(vcc) or defined(icc) :
  proc cpuid(outarray:openarray[int32],functionNumber:int32) =
       cpuidex(cast[ptr int32](outarray[0].unsafeAddr),functionNumber.cint,0)

elif defined(gcc) or defined(clang):        
  proc cpuid(outarray:openarray[int32],functionNumber:int32) =
    {.emit:"""
      int a, b, c, d;
      __asm("cpuid" : "=a"(a), "=b"(b), "=c"(c), "=d"(d) : "a"(functionNumber), "c"(0) : );
      outarray[0] = a;
      outarray[1] = b;
      outarray[2] = c;
      outarray[3] = d;
    """.}    

else:     
  proc cpuid(outarray:openarray[int32],functionNumber:int32) =
    {.emit"""
      __asm
      {
        mov eax, functionNumber
        xor ecx, ecx
        cpuid;
        mov esi, outarray
        mov[esi], eax
        mov[esi + 4], ebx
        mov[esi + 8], ecx
        mov[esi + 12], edx
      }
    ."""}

when defined(vcc) or defined(icc):
  proc xgetbv(x:int) :int64 = return c_xgetbv(x)

elif defined(gcc) or defined(clang):
  proc xgetbv(x:int) :int64 =
    var a,d: uint32
    {.emit"""            
       __asm( "xgetbv" : "=a"(a), "=d"(d) : "c"(x) : );           
    """.}
    return (a.uint64() or (d.uint64() shl 32)).int64()
else:
  proc xgetbv(x:int) :int64 =
    var a,d: uint32
    {.emit"""            
      __asm {
        mov ecx, ctr
        _emit 0x0f
        _emit 0x01
        _emit 0xd0; // xgetbv
        mov a, eax
        mov d, edx
      }            
    """.}
    return (a.uint64() or (d.uint64() shl 32)).int64()

type CPU_TYPE* = enum
  UNINITIALIZED,NO_SIMD,SSE2,SSE41,AVX2

proc getCPUType*() : CPU_TYPE =
  var cpuInfo = newSeq[int32](4)
  cpuid(cpuInfo,0)
  let nIds = cpuInfo[0]

  if nIds == 0: return NO_SIMD

  cpuid(cpuInfo,1)

  if (cpuInfo[3] and (1 shl 0)) == 0: return NO_SIMD
  if (cpuInfo[3] and (1 shl 23)) == 0: return NO_SIMD
  if (cpuInfo[3] and (1 shl 15)) == 0: return NO_SIMD
  if (cpuInfo[3] and (1 shl 24)) == 0: return NO_SIMD
  if (cpuInfo[3] and (1 shl 25)) == 0: return NO_SIMD
  if (cpuInfo[3] and (1 shl 26)) == 0: return NO_SIMD  #actually has SSE be we only support SSE2 and up for now
  if (cpuInfo[2] and (1 shl 0)) == 0: return SSE2
  if (cpuInfo[2] and (1 shl 9)) == 0: return SSE2  #actually ahs SSE3 but we are not that granular for now
  if (cpuInfo[2] and (1 shl 19)) == 0: return SSE2  #actually ahs SSSE3 but we are not that granular for now
  if (cpuInfo[2] and (1 shl 23)) == 0: return SSE41  #no popcount
  if (cpuInfo[2] and (1 shl 20)) == 0: return SSE41 #no sse4.2
  if (cpuInfo[2] and (1 shl 26)) == 0: return SSE41  #actually ahs SSE42 but we are not that granular for now
  if (cpuInfo[2] and (1 shl 27)) == 0: return SSE41  #actually ahs SSE42 but we are not that granular for now
  if (cpuInfo[2] and (1 shl 28)) == 0: return SSE41  #actually ahs SSE42 but we are not that granular for now
  if (xgetbv(0) and 6) != 6: return SSE41 #AVX not enabled in OS
  cpuid(cpuInfo,7)
  if (cpuInfo[1] and (1 shl 5)) == 0: return SSE41 #actually avx but we are not that granual yet
  return AVX2
