
import  httpcore, router
import urlly

type
  Request* = ref object of RootObj
    meth*: HttpMethod
    headers*: HttpHeaders
    protocol*: tuple[major, minor: int]
    url*: typeof(Url()[])
    path*: string              # http req path
    hostname*: string
    ip*: string
    params*: Table[string, string]
    query*: seq[(string, string)]
    
