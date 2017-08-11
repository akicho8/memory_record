$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Direction
  include MemoryRecord
  memory_record [
    {key: :left,  name: '←', vector: [-1,  0]},
    {key: :right, name: '→', vector: [ 1,  0]},
  ], attr_reader_auto: true

  def long_name
    '#{name}方向'
  end
end

Direction.collect(&:name)       # => ['←', '→']
Direction.keys                  # => [:left, :right]

Direction[:right].key           # => :right
Direction[:right].code          # => 1
Direction[:right].vector        # => [1, 0]
Direction[:right].long_name     # => '→方向'

Direction[1].key                # => :right

Direction[:up]                  # => nil
Direction.fetch(:up) rescue $!  # => #<KeyError: Direction.fetch(:up) does not match anything
