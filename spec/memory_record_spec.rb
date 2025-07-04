require 'spec_helper'

RSpec.describe MemoryRecord do
  class Model5
    include MemoryRecord
    memory_record [
      { key: :a },
      { key: :b },
    ]
  end

  class Model
    include MemoryRecord
    memory_record [
      { name: 'A' },
      { name: 'B' },
    ], attr_reader: :name
  end

  class Legacy
    include MemoryRecord
    memory_record [
      { code: 10, key: :a, name: 'A', },
      { code: 20, key: :b, name: 'B', },
    ], attr_reader: :name
  end

  def class_new(table)
    Class.new {
      include MemoryRecord
      memory_record table
    }
  end

  context 'Useful Class Methods' do
    it 'each' do
      assert { Model.each }
    end

    it 'keys' do
      assert { [:_key0, :_key1] == Model.keys }
    end

    it 'values' do
      assert { Model.each.to_a == Model.values }
    end
  end

  context 'Subscript access to class' do
    it 'When code and key are automatically waved' do
      assert { 'A' == Model[0].name }
    end

    it 'It will not cause an error even if there is no corresponding key' do
      assert_nothing_raised { Model[:unknown] }
    end

    it 'In the case of fetch, if there is no corresponding key, an error occurs' do
      assert_raises { Model.fetch(:unknown) }
    end

    it 'fetch_if' do
      assert_nothing_raised { Model.fetch_if(nil) }
    end
  end

  context 'Subscript access to instance' do
    it do
      assert { Model.first[:name] == 'A' }
      assert { Model.first[:xxxx] == nil }
    end
  end

  context 'to_s' do
    it do
      assert { Model.first.to_s == 'A' }
    end
  end

  context 'instance accessor' do
    it do
      assert { Model.first.to_h }
      assert { Model.first.attributes }
      assert { Model.first.key }
      assert { Model.first.code }
    end
  end

  context 'Re-set' do
    before do
      @model = class_new [{key: :a}]
      @model.memory_record_reset [{key: :b}, {key: :c}]
    end
    it 'changed' do
      assert { [:b, :c] == @model.keys }
      assert { [0, 1] == @model.codes }
    end
  end

  context 'Subtle specifications' do
    it 'When keys are specified as an array, they become symbols with underscores' do
      model = class_new [{key: [:id, :desc]}]
      assert { [:id_desc] == model.keys }
    end

    it 'Name method is automatically defined if it is not defined' do
      model = class_new [{key: :foo}]
      assert { true == model.instance_methods.include?(:name) }
      assert { "foo" == model[:foo].name }
    end
  end

  it 'Japanese can be used for key' do
    model = class_new [{key: 'あ'}]
    assert { model['あ'] }
  end

  it 'When you define code and keys yourself' do
    assert { 'A' == Legacy[10].name }
  end

  it 'We do not freeze values because memoization becomes impossible' do
    assert_nothing_raised { Model.first.name.upcase! }
  end

  describe 'super' do
    class Model2
      include MemoryRecord
      memory_record [
        {var: 'x'},
      ], attr_reader: :var

      def var
        super + 'y'
      end
    end

    it 'Since methods are defined in ancestry, you can use super' do
      assert { 'xy' == Model2.first.var }
    end
  end

  describe 'attr_reader' do
    class Model3
      include MemoryRecord
      memory_record [
        {a: 1},
        {b: 2},
      ]
    end

    it do
      assert { 1 == Model3.first.a }
      assert { nil == Model3.first.b }
    end
  end

  describe 'Do not duplicate key and code' do
    it do
      assert_raises(ArgumentError) { Model.memory_record_reset([{key: :a}, {key: :a}]) }
      assert_raises(ArgumentError) { Model.memory_record_reset([{code: 0}, {code: 0}]) }
    end
  end

  describe 'attr_reader option' do
    def element(options)
      Class.new {
        include MemoryRecord
        memory_record **options do
          [
            {x: 1, y: 1, z: 1},
          ]
        end
      }.first
    end

    context 'false' do
      subject { element(attr_reader: false) }
      it do
        assert { subject.respond_to?(:x) == false }
        assert { subject.respond_to?(:y) == false }
        assert { subject.respond_to?(:z) == false }
      end
    end

    context 'only' do
      subject { element(attr_reader: {only: [:x, :z]}) }
      it do
        assert { subject.respond_to?(:x) == true  }
        assert { subject.respond_to?(:y) == false }
        assert { subject.respond_to?(:z) == true  }
      end
    end

    context 'except' do
      subject { element(attr_reader: {except: :y}) }
      it do
        assert { subject.respond_to?(:x) == true  }
        assert { subject.respond_to?(:y) == false }
        assert { subject.respond_to?(:z) == true  }
      end
    end
  end

  it "can call that lookup from foobar when updating inherited lookup" do
    model = class_new [{key: :a}]
    model.singleton_class.class_eval do
      def lookup(*)
        super.key
      end
    end
    assert { model[:a] == :a }
  end

  it "minus" do
    m = class_new [{key: :a}, {key: :b}]
    assert { ([m[:a], m[:b]] - [m[:a]]) == [m[:b]] }
  end

  describe "sort (<=> method)" do
    it "same class" do
      m = class_new [{key: :a}, {key: :b}]
      assert { [m[:b], m[:a]].sort == [m[:a], m[:b]] }
    end

    it "different class" do
      m1 = class_new [{key: :a}, {key: :b}]
      m2 = class_new [{key: :a}, {key: :b}]
      assert_raises(ArgumentError) { [m1[:b], m2[:a]].sort }
    end
  end

  it "eql?, hash" do
    a = Model.fetch(:_key0)
    b = Marshal.load(Marshal.dump(a))
    h = {}
    h[a] = true
    assert { h[b] == true }
  end

  describe "Comparable operator" do
    it do
      model = class_new [
        { key: :a },
        { key: :b },
      ]
      assert { model[:a] < model[:b]  }
      assert { model[:a] == model[:a] }
    end

    it "==" do
      a = Model5.first
      b = Marshal.load(Marshal.dump(a))
      assert { a == b }
    end
  end

  context 'as_json' do
    require "active_model"

    class Person
      include ActiveModel::Model
      include ActiveModel::Serializers::JSON

      attr_accessor :a

      def attributes
        {'a' => a}
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

    it "as_json(options)" do
      assert { ColorInfo.first.as_json(only: :key) == {:key => :blue} }
      assert { ColorInfo.first.as_json(except: [:rgb, :code, :a]) == {:key => :blue} }
      assert { ColorInfo.first.as_json(only: [], methods: :hex) == {:hex => "#0000FF"} }
      assert { ColorInfo.first.as_json(only: [], include: {children: {only: :a}}) == {:children => [{"a" => 1}, {"a" => 1}, {:a => 1}]} }
      assert { ColorInfo.as_json(only: :key) == [{:key => :blue}, {:key => :red}] }
    end
  end

  # broken with version 0.10.10
  # context 'active_model_serializers' do
  #   require "active_model_serializers"
  #
  #   class ColorInfo
  #     include MemoryRecord
  #     memory_record [
  #       { key: :blue, },
  #     ]
  #   end
  #
  #   class ColorInfoSerializer < ActiveModel::Serializer
  #     attributes :key
  #   end
  #
  #   it do
  #     assert { ActiveModelSerializers::SerializableResource.new(ColorInfo.first).as_json == {:key => :blue} }
  #   end
  # end

  describe "lookup_key" do
    it do
      model = class_new [
        { key: :blue },
      ]
      assert { model.lookup_key(:blue)              ==  :blue }
      assert { model.lookup_key(:unknown)           ==  nil   }
      assert { model.lookup_key(:unknown, :blue)    ==  :blue }
      assert { model.lookup_key(:unknown) { :blue } ==  :blue }
      assert { model.lookup_key(:unknown) { :blue } ==  :blue }
      assert_raises(KeyError) { model.lookup_key(:unknown) { :xxx } }
      assert_raises(KeyError) { model.lookup_key(:unknown, :xxx) }
    end
  end

  describe "euqal nil" do
    it do
      model = class_new [
        { key: :blue },
      ]
      assert { model[:blue] != nil }
    end
  end
end
