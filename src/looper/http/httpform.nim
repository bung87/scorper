import json
type 
  HttpRequestFile* = object
  Form* = object
    data*: JsonNode
    files*: seq[HttpRequestFile]