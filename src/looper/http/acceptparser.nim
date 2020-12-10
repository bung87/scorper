import npeg, strutils, algorithm
import npeg/codegen
export npeg

proc sortFunc(x, y: tuple[mime:string,q:float]):int =
  result = cmp(x.q,y.q)
  if result == 0:
    let xoffset = x.mime.find('/')
    let yoffset = y.mime.find('/')
    if xoffset == yoffset and x.mime[0 ..< xoffset] == y.mime[0 ..< yoffset]:
      let xsub = x.mime[xoffset+1 .. ^1]
      let ysub = y.mime[yoffset+1 .. ^1]
      if xsub == ysub:
        return 0
      elif ysub == "*":
        return 1
      elif xsub == "*":
        return -1

proc accpetParser*():Parser[char, seq[tuple[mime: string, q: float]]] = 
  # https://tools.ietf.org/html/rfc7231#section-5.3.2
  result = peg("pairs",d:  seq[tuple[mime:string,q:float]]):
    pairs <- pair * *(',' * * Blank * pair) * eof
    tchar <- Alpha | Digit | '*' | '!' | '#' |
                                '$' | '&' | '-' | '^' | '_' | '/' |  '+'
    token <- +tchar
    DQUOTE <- '"'
    # https://tools.ietf.org/html/rfc5234#appendix-B.1
    VCHAR <- {'\x21' .. '\x7e'}
    quoted_pair <- '\\' * ( Blank | VCHAR | obs_text )
    quoted_string <- DQUOTE * ( qdtext | quoted_pair ) * DQUOTE
    obs_text <- {'\x80' .. '\xff'}
    qdtext <- Blank | '\x21' | {'\x21' .. '\x5b'} | {'\x5d' .. '\x7e'} | obs_text
    
    quoted_string <- Blank
    parameter <- token * '=' * ( token | quoted_string )
    mime <- token
    q <- +( ('0' * ?('.' *  Digit[0..3])) | '1' * ?('.' * '0'[0..3]))
    OWS <- *Blank
    qkey <- 'q' | 'Q'
    pair <- >mime * ?(';' * ((qkey * '=' * >q) | parameter) ):
      if capture.len == 3:
        let q = parseFloat $2
        if q > 0:
          d.add ( mime: $1, q: q )
      else:
        d.add ( mime: $1, q: 1.0 )
    eof <- !1:
      d.sort(sortFunc,order = SortOrder.Descending)