$LOAD_PATH.unshift '../lib'
require 'memory_record'

class C
  include MemoryRecord
  memory_record [{key: :a}]
end

C.keys                          # => [:a]

# Can not update with memory_record
class C
  memory_record [{key: :b}]
end

C.keys                          # => [:a]

# With memory_record_reset you can rebuild data
C.memory_record_reset [{key: :c}]

C.keys                          # => [:c]
