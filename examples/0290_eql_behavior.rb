$LOAD_PATH.unshift '../lib'
require 'memory_record'

class C
  include MemoryRecord
  memory_record [
    {key: :a},
  ]
  def foo
    @foo ||= Object.new
  end
end

a = C[:a]
b = C[:a]

a.eql?(b)                       # => true
b.foo
a.eql?(b)                       # => true

[a, b] - [a]                    # => []
