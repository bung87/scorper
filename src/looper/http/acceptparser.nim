
type 
  AccpetParserState = enum
    mime,par
  AccpetParser* = ref object
    length:int
    i:int
    state:AccpetParserState
    tmpMimes:seq[string]

proc parse*(parser:AccpetParser, value: sink string) =
  parser.length = value.len
  parser.tmpMimes = newSeq[string]()
  while parser.i < parser.length:
    case parser.state
      of mime:
        var j = parser.i
        while true:
          if value[parser.i] == ',':
            parser.tmpMimes.add value[j ..< parser.i]
            parser.state = mime
            inc parser.i
            break
          elif value[parser.i] == ';':
            parser.tmpMimes.add value[j ..< parser.i]
            parser.state = par
            inc parser.i
            break
          else:
            inc parser.i
      of par:
        var j:int
        if value[parser.i] == 'q' or value[parser.i] == 'Q':
          inc parser.i # q
          inc parser.i # =
          j = parser.i
          while value[parser.i] in {'0' .. '9','.'}:
            inc parser.i
            if parser.i == parser.length:
              break
          echo parser.tmpMimes
          echo value[j ..< parser.i]
          parser.tmpMimes.setLen(0)
          inc parser.i
          parser.state = mime

when isMainModule:
  let accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
  echo accept
  var parser = new AccpetParser
  parser.parse(accept)