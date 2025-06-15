$LOAD_PATH.unshift "../lib"
require "memory_record"

class C
  include MemoryRecord
  memory_record [
    {key: :a},
  ]
end

a = C[:a]
b = Marshal.load(Marshal.dump(a))
a == b                          # => true
