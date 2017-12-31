$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Foo
  include MemoryRecord
  memory_record [
    {a: 10},
  ]

  def a
    super * 2
  end

  def name
    "(#{super})"
  end
end

Foo.first.a                     # => 20
Foo.first.name                  # => "(_key0)"
