$LOAD_PATH.unshift '../lib'
require 'memory_record'

class A
  include MemoryRecord
  memory_record [
    { key: :a, x: 1, y: 2 },
  ]

  def z
    x + y
  end
end

class B < A
  memory_record_reset superclass.collect(&:attributes)

  def z
    super * 2
  end
end

B.values # => [#<B:0x00007feea40395b8 @attributes={:key=>:a, :x=>1, :y=>2, :code=>0}>]
B.first.z                       # => 6
