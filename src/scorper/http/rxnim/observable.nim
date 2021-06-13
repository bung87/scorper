import ./types

proc subscribe*[T](self: Observable[T], observer: Observer[T]): Disposable[T] =
  new result
  self.observers.add observer
  result.observer = observer
  result.observable = self

proc unSubscribe*(self: Disposable): void =
  self.observer.dispose()
  let idx = self.observable.observers.find self.observer
  self.observable.observers.del idx

proc newObservable*[T](): Observable[T] =
  result = new Observable[T]
  result.observers = newSeq[Observer[T]]()

proc newObservable*[T](subsribe: proc(subscriber: Observer[T]): void): Observable[T] =
  new result
  result.priSubscribe = subsribe
  result.observers = newSeq[Observer[T]]()
