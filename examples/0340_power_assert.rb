$LOAD_PATH.unshift '../lib'
require 'memory_record'

require "rspec/autorun"

class Foo
  include MemoryRecord
  memory_record [
    { key: "あ"  },
    { key: "い", },
  ]
end

RSpec.configure do |config|
  config.expect_with :test_unit
end

describe do
  it do
    assert { Foo["あ"] == Foo["い"] }
  end
end
