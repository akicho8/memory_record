$LOAD_PATH.unshift "../lib"
require "memory_record"

class Foo
  include MemoryRecord
  memory_record [
    {key: "true",  name: "有効"},
    {key: "false", name: "無効"},
  ], attr_reader: :name
end

flag = true

Foo[flag.to_s].name             # => "有効"
