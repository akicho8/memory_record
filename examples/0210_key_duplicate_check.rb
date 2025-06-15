$LOAD_PATH.unshift "../lib"
require "memory_record"

# An error occurs if key is duplicated

class Foo
  include MemoryRecord
  memory_record [{key: :a}, {key: :a},] rescue $! # => #<ArgumentError:"Foo#key :a is duplicate\nExisting: {key: :a, code: 0}\nConflict: {key: :a, code: 1}">
end

class Bar
  include MemoryRecord
  memory_record [{code: 0}, {code: 0},] rescue $! # => #<ArgumentError:"Bar#code 0 is duplicate\nExisting: {code: 0, key: :_key0}\nConflict: {code: 0, key: :_key1}">
end
