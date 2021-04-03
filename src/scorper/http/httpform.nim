import multipartparser
import strformat
import sequtils

type
  FormData* = ref object
    store: seq[ContentDisposition]
  FormFiles* = ref object
    store: seq[ContentDisposition]
  FormFile* = object
    filename*, contentType*, transferEncoding*: string
    filepath*: string
  Form* = ref object
    data*: FormData
    files*: FormFiles

proc open*(x: FormFile): File = open(x.filepath)

proc readFile*(x: FormFile): string =
  readFile(x.filepath)

proc add*(x: FormData | FormFiles, y: sink ContentDisposition) =
  x.store.add y

proc `$`*(x: FormData | FormFiles): string = $x.store

proc `$`*(x: Form): string =
  result = fmt"""{{"data":{x.data}, "files":{x.files}}}"""

proc newForm*(): Form =
  new result
  result.data = FormData(store: newSeq[ContentDisposition]())
  result.files = FormFiles(store: newSeq[ContentDisposition]())

func `[]`*(x: FormData | FormFiles, key: string): seq[ContentDisposition] =
  filter(x.store, proc(y: ContentDisposition): bool = y.name == key)

converter toString*(values: seq[ContentDisposition]): string =
  for v in values:
    if v.kind == ContentDispositionKind.data:
      return v.value

converter toFormFile*(values: seq[ContentDisposition]): FormFile =
  for v in values:
    if v.kind == ContentDispositionKind.file:
      return FormFile(filename: v.filename, filepath: v.filepath,
          contentType: v.contentType)
