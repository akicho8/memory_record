$LOAD_PATH.unshift '../lib'
require 'memory_record'

class C
  include MemoryRecord
  memory_record [{key: :a}], attr_reader: :name
end

C.keys                          # => [:a]

# memory_record では更新できない
class C
  memory_record [{key: :b}], attr_reader: :name
end

C.keys                          # => [:a]

# memory_record_list_set を使うこと
C.memory_record_list_set [{key: :c}]

C.keys                          # => [:c]