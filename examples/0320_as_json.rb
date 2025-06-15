$LOAD_PATH.unshift "../lib"
require "memory_record"

if true
  require "active_model"

  class Person
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :a

    def attributes
      {"a" => a}
    end
  end
end

class ColorInfo
  include MemoryRecord
  memory_record [
    { key: :blue, rgb: [  0, 0, 255], a: 1},
    { key: :red,  rgb: [255, 0,   0], a: 2},
  ]

  def hex
    "#" + rgb.collect { |e| "%02X" % e }.join
  end

  def children
    [
      {a: 1, b: 2},
      Person.new(a: 1),
      ColorInfo[:blue],
    ]
  end
end

ColorInfo.first.key             # => :blue

ColorInfo.first.as_json                                             # => {key: :blue, rgb: [0, 0, 255], a: 1, code: 0}
ColorInfo.first.as_json(only: :key)                                 # => {key: :blue}
ColorInfo.first.as_json(except: [:rgb, :code, :a])                  # => {key: :blue}
ColorInfo.first.as_json(only: [], methods: :hex)                    # => {hex: "#0000FF"}
ColorInfo.first.as_json(only: [], include: {children: {only: :a}} ) # => {children: [{"a" => 1}, {"a" => 1}, {a: 1}]}
ColorInfo.as_json(only: :key)   # => [{key: :blue}, {key: :red}]
ColorInfo.to_json(only: :key)   # => "[{\"key\":\"blue\"},{\"key\":\"red\"}]"
