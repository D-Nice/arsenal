## candidates for inclusion with some more work?
template redirectOutToErr*(body: untyped) =
  when defined posix:
    discard stdout.reopen("/dev/stderr", fmWrite)
  body
  when defined posix:
    discard stdout.reopen("/dev/stdout", fmWrite)

template handleException*(body: untyped) =
  try:
    body
  except:
    echoErr "Exception: ", getCurrentExceptionMsg()
    quit 1

template onlyInteractive*(body: untyped) =
  if stdin.isatty:
    body

from terminal import readPasswordFromStdin
proc passwordPrompt*(
  prompt: string = "Enter password: ",
  fd: File = stderr
): string =
  # requires: from terminal import readPasswordFromStdin
  fd.write prompt
  fd.flushFile
  result = readPasswordFromStdin("")
  fd.write "\p"

import unicode
func toCompressedCharSet*(buf: seq[byte], base: seq[Rune], width: SomeUnsignedInt = uint64): string =
  for n in toBitWidthLE[byte, width](buf):
    result.add base[n mod base.len.uint]
