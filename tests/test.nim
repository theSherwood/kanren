from ../src/test_utils import failures
from kanren import nil

# Run tests
kanren.main()

when defined(wasm):
  if failures > 0: raise newException(AssertionDefect, "Something failed.")
