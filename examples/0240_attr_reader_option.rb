$LOAD_PATH.unshift "../lib"
require "memory_record"

class C1
  include MemoryRecord
  memory_record attr_reader: false do
    [
      {x: 1, y: 1, z: 1},
    ]
  end
end

C1.first.x rescue $! # => #<NoMethodError: undefined method 'x' for an instance of C1>
C1.first.y rescue $! # => #<NoMethodError: undefined method 'y' for an instance of C1>
C1.first.z rescue $! # => #<NoMethodError: undefined method 'z' for an instance of C1>

class C2
  include MemoryRecord
  memory_record attr_reader: {only: :y} do
    [
      {x: 1, y: 1, z: 1},
    ]
  end
end

C2.first.x rescue $! # => #<NoMethodError: undefined method 'x' for an instance of C2>
C2.first.y rescue $! # => 1
C2.first.z rescue $! # => #<NoMethodError: undefined method 'z' for an instance of C2>

class C3
  include MemoryRecord
  memory_record attr_reader: {except: :y} do
    [
      {x: 1, y: 1, z: 1},
    ]
  end
end

C3.first.x rescue $! # => 1
C3.first.y rescue $! # => #<NoMethodError: undefined method 'y' for an instance of C3>
C3.first.z rescue $! # => 1
