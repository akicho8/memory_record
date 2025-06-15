$LOAD_PATH.unshift "../lib"
require "memory_record"

require "rspec/autorun"

Foo = {}

RSpec.configure do |config|
  config.expect_with :test_unit
end

describe do
  it do
    assert { Foo["あ"] == Foo["い"] }
  end
end
# >> .
# >> 
# >> Finished in 0.00996 seconds (files took 0.12816 seconds to load)
# >> 1 example, 0 failures
# >> 
