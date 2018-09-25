require "bundler/inline"

gemfile do
  gem "memory_record", path: ".."
  gem "active_model_serializers"
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

pp ActiveModelSerializers::SerializableResource.new(ColorInfo.first).as_json # => {:key=>:blue, :name=>"blue"}
# >> [active_model_serializers] Rendered ColorInfoSerializer with ActiveModelSerializers::Adapter::Attributes (0.14ms)
# >> {:key=>:blue, :name=>"blue"}
