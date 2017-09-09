lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'memory_record/version'

Gem::Specification.new do |spec|
  spec.name          = 'memory_record'
  spec.version       = MemoryRecord::VERSION
  spec.authors       = ['akicho8']
  spec.email         = ['akicho8@gmail.com']
  spec.description   = %q{A small number of records easy handling library}
  spec.summary       = %q{A small number of records easy handling library}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'test-unit'

  spec.add_dependency 'activesupport'
  spec.add_dependency 'activemodel'
end
