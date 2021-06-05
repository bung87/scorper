import prologue, json
const port {.intdefine.} = 8080
proc handlePlaintext*(ctx: Context) {.async.} =
  resp plainTextResponse "Hello, World!"

proc handleJson*(ctx: Context) {.async.} =
  resp jsonResponse %*{"message": "Hello, World!"}

var app = newApp(settings = newSettings(debug = false, port = Port(port)))
app.addRoute("/plaintext", handlePlaintext)
app.addRoute("/json", handleJson)
app.run()
