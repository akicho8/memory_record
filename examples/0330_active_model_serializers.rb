require "bundler/inline"

gemfile do
  gem "memory_record", path: ".."
  gem "active_model_serializers", "0.10.7" # It does not work with version 0.10.10
end

class ColorInfo
  include MemoryRecord
  memory_record [
    { key: :blue, },
    { key: :red,  },
  ]
end

class ColorInfoSerializer < ActiveModel::Serializer
  attributes :key, :name
end

pp ActiveModelSerializers::SerializableResource.new(ColorInfo.first).as_json # => 
# ~> /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/resolver.rb:348:in 'Bundler::Resolver#raise_not_found!': Could not find gem 'active_model_serializers (= 0.10.7)' in locally installed gems. (Bundler::GemNotFound)
# ~> 
# ~> The source contains the following gems matching 'active_model_serializers':
# ~>   * active_model_serializers-0.10.15
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/resolver.rb:448:in 'block in Bundler::Resolver#prepare_dependencies'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/resolver.rb:423:in 'Hash#each'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/resolver.rb:423:in 'Enumerable#filter_map'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/resolver.rb:423:in 'Bundler::Resolver#prepare_dependencies'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/resolver.rb:65:in 'Bundler::Resolver#setup_solver'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/resolver.rb:30:in 'Bundler::Resolver#start'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/definition.rb:746:in 'Bundler::Definition#start_resolution'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/definition.rb:342:in 'Bundler::Definition#resolve'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/definition.rb:653:in 'Bundler::Definition#materialize'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/definition.rb:237:in 'Bundler::Definition#specs'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/installer.rb:227:in 'Bundler::Installer#ensure_specs_are_compatible!'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/installer.rb:81:in 'block in Bundler::Installer#run'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/rubygems.rb:835:in 'block in Gem.open_file_with_flock'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/rubygems.rb:823:in 'IO.open'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/rubygems.rb:823:in 'Gem.open_file_with_flock'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/rubygems.rb:809:in 'Gem.open_file_with_lock'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/process_lock.rb:13:in 'block in Bundler::ProcessLock.lock'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/shared_helpers.rb:105:in 'Bundler::SharedHelpers#filesystem_access'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/process_lock.rb:12:in 'Bundler::ProcessLock.lock'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/installer.rb:71:in 'Bundler::Installer#run'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/installer.rb:23:in 'Bundler::Installer.install'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/inline.rb:64:in 'block (2 levels) in Object#gemfile'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/settings.rb:159:in 'Bundler::Settings#temporary'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/inline.rb:63:in 'block in Object#gemfile'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/settings.rb:159:in 'Bundler::Settings#temporary'
# ~> 	from /opt/rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/bundler/inline.rb:58:in 'Object#gemfile'
# ~> 	from -:3:in '<main>'
