
type 
  AccpetParserState = enum
    mime,par,finished
  AccpetParser* = ref object
    length:int
    i:int
    state:AccpetParserState
    tmpMimes:seq[string]
    aSlice:Slice[int] # store name,value pair indexes
    bSlice:Slice[int]


proc parse*(parser:AccpetParser, value: sink string) =
  parser.i = 0
  parser.state = mime
  parser.length = value.len
  parser.tmpMimes = newSeq[string]()
  while parser.i < parser.length:
    case parser.state
      of finished:
        break
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
            echo ";",parser.tmpMimes
            parser.state = par
            inc parser.i
            break
          elif value[parser.i] == ' ':
            inc parser.i
            inc j
          else:
            inc parser.i
        if parser.i == parser.length: # last mime without parameters
          echo parser.tmpMimes
      of par:
        var j:int
        if value[parser.i] == 'q' or value[parser.i] == 'Q':
          inc parser.i # q
          inc parser.i # =
          j = parser.i
          while value[parser.i] in {'0' .. '9','.'}:
            inc parser.i
            if parser.i == parser.length:
              parser.state = finished
              echo value[j ..< parser.i]
              return
          echo "par:",parser.tmpMimes
          echo value[j ..< parser.i]
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
          echo value[parser.aSlice]
          echo value[parser.bSlice]
          parser.tmpMimes.setLen(0)
          while parser.i < parser.length and value[parser.i] == ' ':
            inc parser.i 
          parser.state = mime
          discard

when isMainModule:
  let accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
  echo accept
  var parser = new AccpetParser
  parser.parse(accept)
  let accept2 = "application/json;q=0.6, text/plain;q=0.8"
  echo accept2
  parser.parse(accept2)
  let accept3 = "text/*, text/plain;format=flowed, text/plain, text/plain;level=1, text/html, text/plain;level=2, */*, image/*, text/rich"
  parser.parse(accept3)