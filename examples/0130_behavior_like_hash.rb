$LOAD_PATH.unshift "../lib"
require "memory_record"

class C
  include MemoryRecord
  memory_record [
    {key: :a, x: 1},
  ]
end

C[:a][:x] # => 1
