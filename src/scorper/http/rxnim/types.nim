type
  NextHandle*[T] = proc (value: T): void
  ErrorHandle* = proc (error: Exception): void
  CompletedHandle* = proc (): void
  Observer*[T] = ref object of RootObj
    onNext*: NextHandle[T]
    onError*: ErrorHandle
    onCompleted*: CompletedHandle

type
  Disposable*[T] = ref object of RootObj
    observer*: Observer[T]
    observable*: Observable[T]
  Observable*[T] = ref object of RootObj
    observers*: seq[Observer[T]]
    priSubscribe*: proc(subscriber: Observer[T]): void
