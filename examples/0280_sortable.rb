$LOAD_PATH.unshift '../lib'
require 'memory_record'

class A
  include MemoryRecord
  memory_record [
    {key: :a},
    {key: :b},
  ]
end

[A[:b], A[:a]].sort.collect(&:key) # => [:a, :b]

class B
  include MemoryRecord
  memory_record [
    {key: :a},
  ]
end

# class different
[A[:a], B[:a]].sort.collect(&:key) rescue $! # => #<ArgumentError: comparison of A with B failed>
