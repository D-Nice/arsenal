# these should ideally avoid imports

template ensure*(
  condition: bool,
  errorMsg: string = "Ensure failed",
  exception: type Exception = Exception
) =
  if unlikely condition == false:
    raise exception.newException errorMsg

template echoErr*(msg: varargs[string, `$`]) =
  ## echo but on stderr
  ## useful for unix composability
  stderr.write msg
  stderr.write "\p"
  stderr.flushFile
