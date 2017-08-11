$LOAD_PATH.unshift '../lib'
require 'memory_record'

model = Class.new do
  include MemoryRecord
  memory_record [
    {a: 1},
    {b: 2},
  ], attr_reader_auto: true
end

model.first.name                # => nil
model.first.a                   # => 1
model.first.b                   # => nil
