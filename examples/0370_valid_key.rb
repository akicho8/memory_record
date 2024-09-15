$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Color
  include MemoryRecord
  memory_record [
    { key: :blue },
  ]
end

Color.lookup_key(:blue)                       # => :blue
Color.lookup_key(:unknown)                    # => nil
Color.lookup_key(:unknown, :blue)             # => :blue
Color.lookup_key(:unknown) { :blue }          # => :blue
Color.lookup_key(:unknown) { :xxx } rescue $! # => #<KeyError: Color.fetch(:xxx) does not match anything
