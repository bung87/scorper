import tables
type
  HttpHeaders* = ref object
    table*: TableRef[string, seq[string]]

  HttpHeaderValues* = distinct seq[string]

  HttpCode* = distinct range[0 .. 599]
  HttpVersion* = enum
    HttpVer11 = "HTTP/1.1",
    HttpVer10 = "HTTP/1.0"
    HttpVer20 = "HTTP/2.0"

  HttpMethod* = enum ## the requested HttpMethod
    HttpHead,        ## Asks for the response identical to the one that would
                     ## correspond to a GET request, but without the response
                     ## body.
    HttpGet,         ## Retrieves the specified resource.
    HttpPost,        ## Submits data to be processed to the identified
                     ## resource. The data is included in the body of the
                     ## request.
    HttpPut,         ## Uploads a representation of the specified resource.
    HttpDelete,      ## Deletes the specified resource.
    HttpTrace,       ## Echoes back the received request, so that a client
                     ## can see what intermediate servers are adding or
                     ## changing in the request.
    HttpOptions,     ## Returns the HTTP methods that the server supports
                     ## for specified address.
    HttpConnect,     ## Converts the request connection to a transparent
                     ## TCP/IP tunnel, usually used for proxies.
    HttpPatch        ## Applies partial modifications to a resource.
