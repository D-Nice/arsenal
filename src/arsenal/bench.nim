import
  times,
  strutils

template benchmark*(body: untyped) =
  ## rudimentary benchmark on code within the block
  const callInfo = instantiationInfo()
  const info = "L$1@$2" % [$callInfo.line, callInfo.filename]
  stderr.write "Starting benchmark $1... " % [info]
  let t = epochTime()
  body
  let t2 = epochTime()
  stderr.write "done: ", t2 - t , " seconds\p"
