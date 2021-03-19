import npeg, strutils, sequtils, math, algorithm
import npeg/codegen
export npeg

proc sortFunc(x, y: tuple[mime: string, q: float, extro: int, typScore: int]): int =
  result = cmp(x.q, y.q)
  if result == 0:
    result = cmp(x.typScore, y.typScore)
  if result == 0:
    result = cmp(x.extro, y.extro)

proc accpetParser*(): Parser[char, seq[tuple[mime: string, q: float, extro: int, typScore: int]]] =
  # https://tools.ietf.org/html/rfc7231#section-5.3.2
  result = peg("pairs", d: seq[tuple[mime: string, q: float, extro: int, typScore: int]]):
    pairs <- pair * *(',' * * Blank * pair) * eof
    tchar <- Alpha | Digit | '*' | '!' | '#' |
                                '$' | '&' | '-' | '^' | '_' | '/' | '+'
    token <- +tchar
    DQUOTE <- '"'
    # https://tools.ietf.org/html/rfc5234#appendix-B.1
    VCHAR <- {'\x21' .. '\x7e'}
    quoted_pair <- '\\' * (Blank | VCHAR | obs_text)
    quoted_string <- DQUOTE * (qdtext | quoted_pair) * DQUOTE
    obs_text <- {'\x80' .. '\xff'}
    qdtext <- Blank | '\x21' | {'\x21' .. '\x5b'} | {'\x5d' .. '\x7e'} | obs_text
    value <- token | quoted_string:
      inc d[d.high].extro
    weight <- qkey * '=' * q
    p <- token * '=' * value
    parameter <- weight | p
    parameters <- *(';' * * Blank * parameter)
    mime <- token:
      let mime = $0
      let offset = mime.find('/')
      let mainTyp = mime[0 ..< offset]
      let subTyp = mime[offset+1 .. ^1]
      var typScore: int
      if mainTyp == "*":
        typScore = 0
      elif subTyp == "*":
        typScore = 2
      else:
        typScore = 3
      d.add (mime: $0, q: 1.0, extro: 0, typScore: typScore)
    q <- ('0' * ?('.' * Digit[0..3])) | ('1' * ?('.' * '0'[0..3])):
      let q = parseFloat $0
      d[d.high].q = q
    OWS <- *Blank
    qkey <- 'q' | 'Q'
    pair <- >mime * parameters
    eof <- !1:
      d.sort(sortFunc, order = SortOrder.Descending)
      d.keepItIf(it.q > 0)
