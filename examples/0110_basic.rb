$LOAD_PATH.unshift '../lib'
require 'memory_record'

class Language
  include MemoryRecord
  memory_record [
    {key: :lisp, author: "John McCarthy"      },
    {key: :c,    author: "Dennis Ritchie"     },
    {key: :ruby, author: "Yukihiro Matsumoto" },
  ], attr_reader: true

  def mr_author
    "Mr. #{author}"
  end
end

Language[:ruby].key        # => :ruby
Language[:ruby].code       # => 2
Language[:ruby].author     # => "Yukihiro Matsumoto"
Language[:ruby].mr_author  # => "Mr. Yukihiro Matsumoto"

Language.keys              # => [:lisp, :c, :ruby]
Language.collect(&:author) # => ["John McCarthy", "Dennis Ritchie", "Yukihiro Matsumoto"]
