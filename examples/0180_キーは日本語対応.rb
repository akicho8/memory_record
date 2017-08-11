$LOAD_PATH.unshift "../lib"
require "memory_record"

class Foo
  include MemoryRecord
  memory_record [
    {key: "↑", name: "上"},
  ], attr_reader: :name
end

Foo["↑"].name                  # => "上"
