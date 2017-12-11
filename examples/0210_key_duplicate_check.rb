$LOAD_PATH.unshift '../lib'
require 'memory_record'

# An error occurs if key is duplicated

class Foo
  include MemoryRecord
  memory_record [{key: :a}, {key: :a},] rescue $! # => #<ArgumentError: Foo#key :a is duplicate
end

class Bar
  include MemoryRecord
  memory_record [{code: 0}, {code: 0},] rescue $! # => #<ArgumentError: Bar#code 0 is duplicate
end
