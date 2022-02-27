include ./scorper/http/httpcore

var test = newHttpHeaders()
test["Connection"] = @["Upgrade", "Close"]
doAssert test["Connection", 0] == "Upgrade"
doAssert test["Connection", 1] == "Close"
test.add("Connection", "Test")
doAssert test["Connection", 2] == "Test"
doAssert "upgrade" in test["Connection"]

# Bug #5344.
doAssert parseHeader("foobar: ") == ("foobar", @[""])
let (key, value) = parseHeader("foobar: ")
test = newHttpHeaders()
test[key] = value
doAssert test["foobar"] == ""

doAssert parseHeader("foobar:") == ("foobar", @[""])

block: # test title case
  var testTitleCase = newHttpHeaders()
  testTitleCase.add("content-length", "1")
  doAssert testTitleCase.hasKey("Content-Length")
  for key, val in testTitleCase:
    doAssert key == "Content-Length"

