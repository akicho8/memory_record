$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Palette
  include MemoryRecord
  memory_record [
    { key: :coral,  r: 255, g: 127, b:   0 },
    { key: :tomato, r: 255, g:  99, b:  71 },
    { key: :gold,   r: 255, g: 215, b:   0 },
  ]

  def rgb
    [r, g, b]
  end

  def hex
    "#" + rgb.collect { |e| "%02X" % e }.join
  end

  def name
    super.capitalize
  end
end

Palette[:tomato].key        # => :tomato
Palette[:tomato].name       # => "Tomato"
Palette[:tomato].rgb        # => [255, 99, 71]
Palette[:tomato].hex        # => "#FF6347"
Palette.collect(&:hex)      # => ["#FF7F00", "#FF6347", "#FFD700"]

Palette.lookup_key(:tomato)          # => :tomato
Palette.lookup_key("tomato")         # => :tomato
Palette.lookup_key(1)                # => :tomato
Palette.lookup_key(:xxx)             # => nil
Palette.lookup_key(:xxx, :tomato)    # => :tomato
Palette.lookup_key(:xxx) { :tomato } # => :tomato

Palette.lookup_key(:xxx, :tomato) # => :tomato
Palette.lookup_key(:xxx, :black) rescue $! # => #<KeyError: Palette.fetch(:black) does not match anything
