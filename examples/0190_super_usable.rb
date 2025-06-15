$LOAD_PATH.unshift "../lib"
require "memory_record"

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

  def to_h
    super.merge(x: 1)
  end
end

Foo.first.a                     # => 20
Foo.first.name                  # => "(_key0)"
Foo.first.to_h                  # => {a: 10, code: 0, key: :_key0, x: 1}
