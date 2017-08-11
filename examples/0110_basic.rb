$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Foo
  include MemoryRecord
  memory_record [
    {key: :male,   name: 'otoko'},
    {key: :female, name: 'onna'},
  ], attr_reader: :name
end

Foo[:male]   # => #<Foo:0x007ff459a494a8 @attributes={:key=>:male, :name=>"otoko", :code=>0}>
Foo[:female] # => #<Foo:0x007ff459a49390 @attributes={:key=>:female, :name=>"onna", :code=>1}>

Foo[:male].name                 # => "otoko"
Foo[:female].name               # => "onna"
