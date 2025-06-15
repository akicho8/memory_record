$LOAD_PATH.unshift "../lib"
require "memory_record"

class A
  include MemoryRecord
  memory_record [
    { key: :foo },
  ]

  def name
    super.to_s.upcase
  end
end

class B < A
  memory_record_reset superclass.collect(&:attributes)

  def name
    "(#{super})"
  end
end

A.first.name                    # => "FOO"
B.first.name                    # => "(FOO)"
