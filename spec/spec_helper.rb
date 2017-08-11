$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'memory_record'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end
  config.expect_with :test_unit
end
