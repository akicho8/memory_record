$LOAD_PATH.unshift "../lib"
require "memory_record"

class Foo
  include MemoryRecord
  memory_record [
    { key: :a, },
    { key: :b, },
  ]
end

Foo[:a] == Foo[:a]              # => true
Foo[:a] == Foo[:b]              # => false
Foo[:a] < Foo[:b]               # => true
