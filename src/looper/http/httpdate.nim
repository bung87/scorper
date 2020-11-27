import times
proc httpDate*(datetime: DateTime): string =
  ## Returns ``datetime`` formated as HTTP full date (RFC-822).
  ## ``Note``: ``datetime`` must be in UTC/GMT zone.
  result = datetime.format("ddd, dd MMM yyyy HH:mm:ss") & " GMT"

proc httpDate*(t: Time): string =
  ## Returns ``datetime`` formated as HTTP full date (RFC-822).
  ## ``Note``: ``datetime`` must be in UTC/GMT zone.
  result = t.format("ddd, dd MMM yyyy HH:mm:ss",utc()) & " GMT"

proc httpDate*(): string {.inline.} =
  ## Returns current datetime formatted as HTTP full date (RFC-822).
  result = utc(now()).httpDate()