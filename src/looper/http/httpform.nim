import multipartparser
import strformat
import sequtils

type 
  FormData* = ref object
    store:seq[ContentDisposition]
  FormFiles* = ref object
    store:seq[ContentDisposition]
  FormFile* = object
    filename*,contentType*,transferEncoding*:string
    filepath*:string
  Form* = ref object
    data*: FormData
    files*: FormFiles

proc open*(x:FormFile):File = open(x.filepath)

proc readFile*(x:FormFile): TaintedString {.tags: [ReadIOEffect], gcsafe,
    locks: 0, raises: [IOError].} =
  readFile(x.filepath)

proc add*(x: FormData | FormFiles,y: sink ContentDisposition) =
  x.store.add y

proc `$`*(x:FormData | FormFiles):string = $x.store

proc `$`*(x:Form):string =
  result = fmt"""{{"data":{x.data}, "files":{x.files}}}"""

proc newForm*():Form =
  new result
  result.data = FormData(store:newSeq[ContentDisposition]())
  result.files = FormFiles(store:newSeq[ContentDisposition]())

func `[]`*(x: FormData | FormFiles, key: string): seq[ContentDisposition] =
  filter(x.store, proc(y: ContentDisposition): bool = y.name == key)

converter toString*(values: seq[ContentDisposition]): string =
  doAssert values[0].kind == ContentDispositionKind.data
  return values[0].value

converter toFormFile*(values: seq[ContentDisposition]): FormFile =
  var v = values[0]
  return FormFile(filename:v.filename,filepath:v.filepath,contentType:v.contentType,transferEncoding:v.transferEncoding)