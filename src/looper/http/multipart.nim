
import mimetypes, os, strutils, ./httpcore
import httpform
type
  MultipartEntry* = object
    name*, content*: string
    case isFile*: bool
    of true:
      filename*, contentType*: string
      fileSize*: int64
      isStream*: bool
    else: discard

  MultipartEntries* = openArray[tuple[name, content: string]]
  MultipartData* = ref object
    entries*: seq[MultipartEntry]

  ProtocolError* = object of IOError ## exception that is raised when server
                                     ## does not conform to the implemented
                                     ## protocol

  HttpRequestError* = object of IOError ## Thrown in the ``getContent`` proc
                                        ## and ``postContent`` proc,
                                        ## when the server returns an error

proc newMultipartData*: MultipartData {.inline.} =
  ## Constructs a new ``MultipartData`` object.
  MultipartData()

proc `$`*(data: MultipartData): string =
  ## convert MultipartData to string so it's human readable when echo
  const sep = "-".repeat(30)
  for pos, entry in data.entries:
    result.add(sep & center($pos, 3) & sep)
    result.add("\nname=\"" & entry.name & "\"")
    if entry.isFile:
      result.add("; filename=\"" & entry.filename & "\"\n")
      result.add("Content-Type: " & entry.contentType)
    result.add("\n\n" & entry.content & "\n")

proc add*(p: MultipartData, name, content: string, filename: string = "",
          contentType: string = "", useStream = true) =
  ## Add a value to the multipart data.
  ##
  ## When ``useStream`` is ``false``, the file will be read into memory.
  ##
  ## Raises a ``ValueError`` exception if
  ## ``name``, ``filename`` or ``contentType`` contain newline characters.
  if {'\c', '\L'} in name:
    raise newException(ValueError, "name contains a newline character")
  if {'\c', '\L'} in filename:
    raise newException(ValueError, "filename contains a newline character")
  if {'\c', '\L'} in contentType:
    raise newException(ValueError, "contentType contains a newline character")

  var entry = MultipartEntry(
    name: name,
    content: content,
    isFile: filename.len > 0
  )

  if entry.isFile:
    entry.isStream = useStream
    entry.filename = filename
    entry.contentType = contentType

  p.entries.add(entry)

proc add*(p: MultipartData, xs: MultipartEntries): MultipartData
         {.discardable.} =
  ## Add a list of multipart entries to the multipart data ``p``. All values are
  ## added without a filename and without a content type.
  ##
  ## .. code-block:: Nim
  ##   data.add({"action": "login", "format": "json"})
  for name, content in xs.items:
    p.add(name, content)
  result = p

proc newMultipartData*(xs: MultipartEntries): MultipartData =
  ## Create a new multipart data object and fill it with the entries ``xs``
  ## directly.
  ##
  ## .. code-block:: Nim
  ##   var data = newMultipartData({"action": "login", "format": "json"})
  result = MultipartData()
  for entry in xs:
    result.add(entry.name, entry.content)

proc addFiles*(p: MultipartData, xs: openArray[tuple[name, file: string]],
               mimeDb = newMimetypes(), useStream = true):
               MultipartData {.discardable.} =
  ## Add files to a multipart data object. The files will be streamed from disk
  ## when the request is being made. When ``stream`` is ``false``, the files are
  ## instead read into memory, but beware this is very memory ineffecient even
  ## for small files. The MIME types will automatically be determined.
  ## Raises an ``IOError`` if the file cannot be opened or reading fails. To
  ## manually specify file content, filename and MIME type, use ``[]=`` instead.
  ##
  ## .. code-block:: Nim
  ##   data.addFiles({"uploaded_file": "public/test.html"})
  for name, file in xs.items:
    var contentType: string
    let (_, fName, ext) = splitFile(file)
    if ext.len > 0:
      contentType = mimeDb.getMimetype(ext[1..ext.high], "")
    let content = if useStream: file else: readFile(file).string
    p.add(name, content, fName & ext, contentType, useStream = useStream)
  result = p

proc `[]=`*(p: MultipartData, name, content: string) {.inline.} =
  ## Add a multipart entry to the multipart data ``p``. The value is added
  ## without a filename and without a content type.
  ##
  ## .. code-block:: Nim
  ##   data["username"] = "NimUser"
  p.add(name, content)

proc `[]=`*(p: MultipartData, name: string,
            file: tuple[name, contentType, content: string]) {.inline.} =
  ## Add a file to the multipart data ``p``, specifying filename, contentType
  ## and content manually.
  ##
  ## .. code-block:: Nim
  ##   data["uploaded_file"] = ("test.html", "text/html",
  ##     "<html><head></head><body><p>test</p></body></html>")
  p.add(name, file.content, file.name, file.contentType, useStream = false)


proc format*(entry: MultipartEntry, boundary: string): string =
  result = "--" & boundary & CRLF
  result.add("Content-Disposition: form-data; name=\"" & entry.name & "\"")
  if entry.isFile:
    result.add("; filename=\"" & entry.filename & "\"" & CRLF)
    result.add("Content-Type: " & entry.contentType & CRLF)
  else:
    result.add(CRLF & CRLF & entry.content)