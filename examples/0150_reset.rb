$LOAD_PATH.unshift '../lib'
require 'memory_record'

class C
  include MemoryRecord
  memory_record [{key: :a}]
end

C.keys                          # => [:a]

# memory_record では更新できない
class C
  memory_record [{key: :b}]
end

C.keys                          # => [:a]

# memory_record_reset を使うこと
C.memory_record_reset [{key: :c}]

C.keys                          # => [:c]
