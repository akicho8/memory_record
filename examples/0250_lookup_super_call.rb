$LOAD_PATH.unshift '../lib'
require 'memory_record'

class C
  include MemoryRecord
  memory_record [
    {key: :alice}
  ]

  class << self
    def self.lookup(v)
      p __method__
      super
    end
  end
end

C.lookup(:alice)                # => #<C:0x00007ffe599ba4d8 @attributes={:key=>:alice, :code=>0}>
C[:alice]                       # => #<C:0x00007ffe599ba4d8 @attributes={:key=>:alice, :code=>0}>
