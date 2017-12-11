$LOAD_PATH.unshift '../lib'
require 'memory_record'

class C1
  include MemoryRecord
  memory_record attr_reader: false do
    [
      {x: 1, y: 1, z: 1},
    ]
  end
end

C1.first.x rescue $! # => #<NoMethodError: undefined method `x' for #<C1:0x007f93579027d8>>
C1.first.y rescue $! # => #<NoMethodError: undefined method `y' for #<C1:0x007f93579027d8>>
C1.first.z rescue $! # => #<NoMethodError: undefined method `z' for #<C1:0x007f93579027d8>>

class C2
  include MemoryRecord
  memory_record attr_reader: {only: :y} do
    [
      {x: 1, y: 1, z: 1},
    ]
  end
end

C2.first.x rescue $! # => #<NoMethodError: undefined method `x' for #<C2:0x007f93578e2550>>
C2.first.y rescue $! # => 1
C2.first.z rescue $! # => #<NoMethodError: undefined method `z' for #<C2:0x007f93578e2550>>

class C3
  include MemoryRecord
  memory_record attr_reader: {except: :y} do
    [
      {x: 1, y: 1, z: 1},
    ]
  end
end

C3.first.x rescue $! # => 1
C3.first.y rescue $! # => #<NoMethodError: undefined method `y' for #<C3:0x007f93578c2278>>
C3.first.z rescue $! # => 1
