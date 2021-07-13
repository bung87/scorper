import ./mroutes
import ./scorper / http / [streamserver, router]
import ./scorper / http / routermacros
import macros
from os import nil

doAssert getImports(currentSourcePath) == @["handler", "handler2"]

let r = newRouter[ScorperCallback]()
r.mount(mroutes)
doAssert r.len == 2

