$LOAD_PATH.unshift "../lib"
require "memory_record"

model = Class.new do
  include MemoryRecord
  memory_record [
    {foo: 1},
    {foo: 2},
  ], attr_reader_auto: true
end

model.first.name                # => nil
