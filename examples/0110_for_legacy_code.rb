$LOAD_PATH.unshift "../lib"
require "memory_record"

# It is better to stop allocating code yourself

class Foo
  include MemoryRecord
  memory_record [
    {code: 1, key: :a, name: "A"},
    {code: 2, key: :b, name: "B"},
    {code: 3, key: :c, name: "C"},
  ]
end

Foo[2].name                     # => "B"
Foo[:b].name                    # => "B"
