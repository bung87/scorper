import strutils, algorithm

type 
  AccpetParserState = enum
    mime,par
  AccpetParser* = ref object
    length:int
    i:int
    state:AccpetParserState
    tmpMimes:seq[string]
    aSlice:Slice[int] # store name,value pair indexes
    bSlice:Slice[int]
    tmpQuality:float

proc resetSlices(parser:AccpetParser) {.inline.} =
  parser.aSlice = default(Slice[int])
  parser.bSlice = default(Slice[int])

template debug(a:varargs[untyped]) =
  when defined(DebugAcceptParser):
    debug a

proc sortFunc(x, y: tuple[items:seq[string],quality:float]):int =
  result = cmp(x.quality,y.quality)

proc parse*(parser:AccpetParser, value: sink string):seq[tuple[items:seq[string],quality:float]] =
  parser.resetSlices
  parser.i = 0
  parser.state = mime
  parser.length = value.len
  parser.tmpMimes = newSeq[string]()
  block outter:
    while parser.i < parser.length:
      case parser.state
        of mime:
          var j = parser.i
          while parser.i < parser.length:
            if value[parser.i] == ',':
              if parser.i != j:
                parser.tmpMimes.add value[j ..< parser.i]
              parser.state = mime
              inc parser.i
              break
            elif value[parser.i] == ';':
              parser.tmpMimes.add value[j ..< parser.i]
              debug ";",parser.tmpMimes
              parser.state = par
              inc parser.i
              break
            elif value[parser.i] == ' ':
              inc parser.i
              inc j
            else:
              inc parser.i
          if parser.i == parser.length: # last mime without parameters
            debug parser.tmpMimes
        of par:
          var j:int
          if value[parser.i] == 'q' or value[parser.i] == 'Q':
            inc parser.i # q
            inc parser.i # =
            j = parser.i
            while value[parser.i] in {'0' .. '9','.'}:
              inc parser.i
              if parser.i == parser.length:
                debug value[j ..< parser.i]
                parser.tmpQuality = parseFloat(value[j ..< parser.i])
                if parser.tmpQuality != 0:
                  result.add (items:parser.tmpMimes,quality: parser.tmpQuality)
                break outter
                
            debug "par:",parser.tmpMimes
            debug value[j ..< parser.i]
            parser.tmpQuality = parseFloat(value[j ..< parser.i])
            if parser.tmpQuality != 0:
              result.add (items:parser.tmpMimes,quality: parser.tmpQuality)
            parser.tmpMimes.setLen(0)
            inc parser.i
            parser.state = mime
          else: # level=1 format=flowed
            parser.aSlice.a = parser.i
            parser.aSlice.b = parser.i
            while parser.i < parser.length and value[parser.i] != '=':
              inc parser.i 
              inc parser.aSlice.b
            inc parser.i # =
            parser.bSlice.a = parser.i
            parser.bSlice.b = parser.i
            while parser.i < parser.length and value[parser.i] != ',':
              inc parser.i 
              inc parser.bSlice.b
            parser.aSlice.b -= 1
            parser.bSlice.b -= 1
            debug value[parser.aSlice]
            debug value[parser.bSlice]
            result.add (items:parser.tmpMimes,quality: 1.0)
            parser.tmpMimes.setLen(0)
            while parser.i < parser.length and value[parser.i] == ' ':
              inc parser.i 
            parser.state = mime
            discard

  result.sort(sortFunc,order = SortOrder.Descending)
