$LOAD_PATH.unshift "../lib"
require "memory_record"

class Foo
  include MemoryRecord
  memory_record [
    {key: "true",  name: "ON"},
    {key: "false", name: "OFF"},
  ]
end

flag = true

Foo[flag.to_s].name             # => "ON"
