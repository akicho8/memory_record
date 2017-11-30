$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Foo
  include MemoryRecord
  memory_record [
    {key: :a},
  ]

  def a
    @var ||= 1
  end

  each do |e|
    e.a
    e.freeze
  end
end

v = Foo.first # => #<Foo:0x007f8de5198398 @attributes={:key=>:a, :code=>0}, @var=1>
v.frozen?     # => true
v.a           # => 1
