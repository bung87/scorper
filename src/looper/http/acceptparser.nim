import npeg, strutils, algorithm
import npeg/codegen
export npeg

proc sortFunc(x, y: tuple[mime:string,q:float]):int =
  result = cmp(x.q,y.q)

proc accpetParser*():Parser[char, seq[tuple[mime: string, q: float]]] = 
  result = peg("pairs",d:  seq[tuple[mime:string,q:float]]):
    pairs <- pair * *(',' * * Blank * pair) * eof
    mime <- +(Alpha | Digit | '*' | '!' | '#' |
                                '$' | '&' | '-' | '^' | '_' | '/' |  '+')
    q <- +(Digit | '.')
    pair <- >mime * ?(';' * ('q' | 'Q') * '=' * >q):
      if capture.len == 3:
        let q = parseFloat $2
        if q > 0:
          d.add ( mime: $1, q: q )
      else:
        d.add ( mime: $1, q: 1.0 )
    eof <- !1:
      d.sort(sortFunc,order = SortOrder.Descending)