template suite*(name, body) =

  suite name:

    ## Runs before all tests in the suite
    template setupAll(setupAllBody) {.used.} =
      let b = proc {.async.} = setupAllBody
      waitFor b()

    ## Runs after all tests in the suite
    template teardownAll(teardownAllBody) {.used.} =
      template teardownAllIMPL: untyped {.inject.} =
        let a = proc {.async.} = teardownAllBody
        waitFor a()

    template setup(setupBody) {.used.} =
      setup:
        let asyncproc = proc {.async.} = setupBody
        waitFor asyncproc()

    template teardown(teardownBody) {.used.} =
      teardown:
        let exception = getCurrentException()
        let asyncproc = proc {.async.} = teardownBody
        waitFor asyncproc()
        setCurrentException(exception)

    let suiteproc = proc = # Avoids GcUnsafe2 warnings with chronos
      body

      when declared(teardownAllIMPL):
        teardownAllIMPL()

    suiteproc()

template test*(name, body) =
  test name:
    let asyncproc = proc {.async.} = body
    waitFor asyncproc()
