import looper
when isMainModule:
  proc cb(req: Request) {.async.} =
    echo req.hostname
    echo req.meth
    echo req.headers
    echo req.protocol
    echo req.url
    let headers = {"Date": "Tue, 29 Apr 2014 23:40:08 GMT",
        "Content-type": "text/plain; charset=utf-8"}
    await req.resp("Hello World")
  let address = initTAddress("127.0.0.1:8888")
  waitFor serve(address,cb)