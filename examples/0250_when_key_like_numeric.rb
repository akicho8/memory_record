$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Foo
  include MemoryRecord
  memory_record [
    {key: '01', name: '→'},
    {key: '02', name: '←'},
  ], attr_reader: :name
end

Foo['01'] # => #<Foo:0x007fac2c35db28 @attributes={:key=>:'01', :name=>'→', :code=>0}>
Foo['02'] # => #<Foo:0x007fac2c35d9e8 @attributes={:key=>:'02', :name=>'←', :code=>1}>

# このようにもできるがまったくオススメできない
# マジックナンバーを増やすメリットはない
# なんのためにキーがあるのか考えよう
