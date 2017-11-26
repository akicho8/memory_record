$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Foo
  include MemoryRecord
  memory_record [
    {key: :a, other_key: :x},
    {key: :b, other_key: :y},
    {key: :c, other_key: :z},
  ]

  class << self
    def lookup(v)
      super || invert_table[v]
    end

    private

    def invert_table
      @invert_table ||= inject({}) {|a, e| a.merge(e.other_key => e) }
    end
  end
end

Foo[:a] == Foo[:x]                  # => true
Foo[:b] == Foo[:y]                  # => true
Foo[:c] == Foo[:z]                  # => true
