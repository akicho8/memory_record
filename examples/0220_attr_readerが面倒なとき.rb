$LOAD_PATH.unshift "../lib"
require "memory_record"

class Foo
  include MemoryRecord
  memory_record [
    {a: 1},
    {b: 2},
  ], attr_reader_auto: true
end

Foo.first.a                     # => 1
Foo.first.b                     # => nil
