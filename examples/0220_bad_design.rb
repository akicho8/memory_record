$LOAD_PATH.unshift '../lib'
require 'memory_record'

# I can do it like this, but I can not recommend it at all
# Do not increase the magic number
# Let"s see what key there is for

class Foo
  include MemoryRecord
  memory_record [
    {key: "01", name: "left"},
    {key: "02", name: "right"},
  ]
end

Foo["01"] # => #<Foo:0x00007fb30e1ddcd8 @attributes={:key=>:"01", :name=>"left", :code=>0}>
Foo["02"] # => #<Foo:0x00007fb30e1ddbc0 @attributes={:key=>:"02", :name=>"right", :code=>1}>
