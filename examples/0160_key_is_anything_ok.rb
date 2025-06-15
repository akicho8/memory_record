$LOAD_PATH.unshift "../lib"
require "memory_record"

class Foo
  include MemoryRecord
  memory_record [
    {key: "↑", name: "UP"},
  ]
end

Foo["↑"].name                  # => "UP"
