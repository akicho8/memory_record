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

C.lookup(:alice)                # => #<C:0x007f92c2addf98 @attributes={:key=>:alice, :code=>0}>
C[:alice]                       # => #<C:0x007f92c2addf98 @attributes={:key=>:alice, :code=>0}>
