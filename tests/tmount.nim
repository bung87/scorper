import ./mroutes
import ./scorper/http / [streamserver, router,routermacros]
import macros
let r = newRouter[ScorperCallback]()
r.mount(mroutes)
doAssert r.len == 2