$LOAD_PATH.unshift "../lib"
require "memory_record"

class Foo
  include MemoryRecord
  memory_record [
    {key: "01", name: "右"},
    {key: "02", name: "左"},
  ], attr_reader: :name
end

Foo["01"] # => #<Foo:0x007fac2c35db28 @attributes={:key=>:"01", :name=>"右", :code=>0}>
Foo["02"] # => #<Foo:0x007fac2c35d9e8 @attributes={:key=>:"02", :name=>"左", :code=>1}>

# このようにもできるがまったくオススメできない
# マジックナンバーを増やすメリットはない
# なんのためにキーがあるのか考えよう
