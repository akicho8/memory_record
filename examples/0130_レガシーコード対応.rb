$LOAD_PATH.unshift "../lib"
require "memory_record"

class Foo
  include MemoryRecord
  memory_record [
    {code: 1, key: :a, name: "A"},
    {code: 2, key: :b, name: "B"},
    {code: 3, key: :c, name: "C"},
  ], :attr_reader => :name
end

Foo[2].name                     # => "B"
Foo[:b].name                    # => "B"
