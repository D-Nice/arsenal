import
  endians

converter toBE*[T](x: var T): T =
  ## converts a seq into 
  ## TODO can probably support openArray
  when T is not seq: {.fatal: "Incompatible type, expected seq".}
  if x.len == 0:
    return
  const bitWidth = sizeof x[0]
  result = x
  when bitWidth != sizeof uint8:
    when bitWidth == sizeof uint16:
      const conv = bigEndian16
    elif bitWidth == sizeof uint32:
      const conv = bigEndian32
    elif bitWidth == sizeof uint64:
      const conv = bigEndian64
    for i in x.low .. x.high:
      result[i].addr.conv x[i].addr
  return

converter toLE*[T](x: var T): T =
  ## converts a seq into 
  when T is not seq: {.fatal: "Incompatible type, expected seq".}
  if x.len == 0:
    return
  const bitWidth = sizeof x[0]
  result = x
  when bitWidth != sizeof uint8:
    when bitWidth == sizeof uint16:
      const conv = littleEndian16
    elif bitWidth == sizeof uint32:
      const conv = littleEndian32
    elif bitWidth == sizeof uint64:
      const conv = littleEndian64
    for i in x.low .. x.high:
      result[i].addr.conv x[i].addr
  return

converter toBitWidthLE*[F, T](f: seq[F]): seq[T] =
  # Input is expected to be LE, and output is likewise returned as LE in corresponding bitwidth
  # It does not require an exact word match (e.g. you can have 3 8-bits, and convert it into 2 16-bits even)
  when F is not SomeUnsignedInt or T is not SomeUnsignedInt:
    {.fatal: "Incompatible types, expected some uint".}
  const toHigher = T.sizeof > F.sizeof
  when toHigher:
    ## a higher bitwidth actually yields a smaller length seq (as more bits can fit into it ofc)
    const ratio = T.sizeof div F.sizeof
  else:
    const ratio = F.sizeof div T.sizeof
  when ratio == 1:
    const callPos = instantiationInfo()
    {.hint: "Detected potentially needless bit-width change at L" & $callPos.line & " in " & callPos.filename.}
    return f
  else:
    var fCopy: seq[F]
    when toHigher:
      fCopy.shallowCopy f
    else:
      fCopy = f
      fCopy.setLen f.len * ratio
    result = cast[seq[T]](fCopy)
    # includes partial word if available with min statement
    when toHigher:
      let partialWord = min(f.len mod ratio, 1)
      let newLen = f.len div ratio + partialWord
      result.setLen newLen
      cast[ptr ContainerHeader](result).capacity = newLen
    when system.cpuEndian == bigEndian:
      # for consistency across systems, we ensure the conversion is in LE
      result = result.toLE
    return

converter toBitWidthBE*[F, T](f: seq[F]): seq[T] =
  # Input is expected to be LE, and output is likewise returned as LE in corresponding bitwidth
  # It does not require an exact word match (e.g. you can have 3 8-bits, and convert it into 2 16-bits even)
  when F is not SomeUnsignedInt or T is not SomeUnsignedInt:
    {.fatal: "Incompatible types, expected some uint".}
  const toHigher = T.sizeof > F.sizeof
  when toHigher:
    ## a higher bitwidth actually yields a smaller length seq (as more bits can fit into it ofc)
    const ratio = T.sizeof div F.sizeof
  else:
    const ratio = F.sizeof div T.sizeof
  when ratio == 1:
    const callPos = instantiationInfo()
    {.hint: "Detected potentially needless bit-width change at L" & $callPos.line & " in " & callPos.filename.}
    return f
  else:
    var fCopy: seq[F]
    when toHigher:
      fCopy.shallowCopy f
    else:
      fCopy = f
      fCopy.setLen f.len * ratio
    result = cast[seq[T]](fCopy)
    # includes partial word if available with min statement
    when toHigher:
      let partialWord = min(f.len mod ratio, 1)
      let newLen = f.len div ratio + partialWord
      result.setLen newLen
      cast[ptr ContainerHeader](result).capacity = newLen
    when system.cpuEndian == littleEndian:
      # for consistency across systems, we ensure the conversion is in LE
      result = result.toBE
    return
