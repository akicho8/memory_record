$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Color
  include MemoryRecord
  memory_record [
    { key: :blue },
  ]
end

Color.valid_key(:blue)                       # => :blue
Color.valid_key(:unknown)                    # => nil
Color.valid_key(:unknown, :blue)             # => :blue
Color.valid_key(:unknown) { :blue }          # => :blue
Color.valid_key(:unknown) { :xxx } rescue $! # => #<KeyError: Color.fetch(:xxx) does not match anything
