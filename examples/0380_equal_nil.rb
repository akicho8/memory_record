$LOAD_PATH.unshift "../lib"
require "memory_record"

class A
  include MemoryRecord
  memory_record [
    { key: :x },
  ]
end

class B
  include MemoryRecord
  memory_record [
    { key: :x },
  ]
end

A[:x] != nil                    # => true
[A[:x], B[:x]].sort rescue $!   # => #<ArgumentError: comparison of A with B failed>
