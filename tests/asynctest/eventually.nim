import std/times except milliseconds

template eventually*(expression: untyped, timeout=5000): bool =

  template sleep(millis: int): auto =
    when compiles(await sleepAsync(millis.milliseconds)):
      sleepAsync(millis.milliseconds) # chronos
    else:
      sleepAsync(millis) # asyncdispatch

  proc eventually: Future[bool] {.async.} =
    let endTime = getTime() + initDuration(milliseconds=timeout)
    while not expression:
      if endTime < getTime():
        return false
      await sleep(10)
    return true

  await eventually()
