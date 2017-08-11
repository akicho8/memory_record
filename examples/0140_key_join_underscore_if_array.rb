$LOAD_PATH.unshift '../lib'
require 'memory_record'

class C
  include MemoryRecord
  memory_record [
    {key: [:a, :b]},
  ]
end

C.keys                          # => [:a_b]
