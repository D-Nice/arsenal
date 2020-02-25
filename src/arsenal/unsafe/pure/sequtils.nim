type
  ContainerHeader* = object
    lengh*, capacity*: int

{.
  push
  inline
.}

func cap*(x: var seq | var string): int =
  ## this is safe
  cast[ptr ContainerHeader](x).capacity

func setUncheckedCap*(x: var seq | var string, toCap: Natural) =
  ## You should only ever decrease this...
  cast[ptr ContainerHeader](x).capacity = toCap

func setCap*(x: var seq | var string, toCap: Natural) =
  ## Enforces that cap only ever decreases (which is "safer")
  ## TODO look into whether length should be checked as well
  if toCap < x.cap:
    cast[ptr ContainerHeader](x).capacity = toCap

{.pop.}
