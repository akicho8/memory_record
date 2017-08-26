# If you freeze it will not be able to make these memos

$LOAD_PATH.unshift '../lib'
require 'memory_record'

class C
  def self.x
    @x ||= 'OK'
  end
end

class C2
  include MemoryRecord
  memory_record [
    {model: C},
  ]

  def x
    @x ||= 'OK'
  end
end

C2.first.x                      # => "OK"
C2.first.model.x                # => "OK"
