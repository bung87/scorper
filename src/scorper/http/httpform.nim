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

func `[]`*(x: FormData, key: string): string =
  for v in x.store:
    if v.name == key:
      return v.value

converter toSeqString*(x: FormFiles): seq[string] =
  x.store.mapIt(it.filepath)

converter toSeqFormFile*(x: FormFiles): seq[FormFile] =
  x.store.mapIt(FormFile(filename: it.filename, filepath: it.filepath,
          contentType: it.contentType))

converter toSeqString*(x: FormData): seq[string] =
  x.store.mapIt(it.value)

converter toString*(values: seq[ContentDisposition]): string =
  for v in values:
    if v.kind == ContentDispositionKind.data:
      return v.value

converter toFormFile*(values: seq[ContentDisposition]): FormFile =
  for v in values:
    if v.kind == ContentDispositionKind.file:
      return FormFile(filename: v.filename, filepath: v.filepath,
          contentType: v.contentType)
