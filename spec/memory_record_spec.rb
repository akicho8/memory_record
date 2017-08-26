require 'spec_helper'

class Model
  include MemoryRecord
  memory_record [
    {name: 'A'},
    {name: 'B'},
  ], attr_reader: :name
end

class Legacy
  include MemoryRecord
  memory_record [
    {code: 10, key: :a, name: 'A'},
    {code: 20, key: :b, name: 'B'},
  ], attr_reader: :name
end

RSpec.describe MemoryRecord do
  def __define(table)
    Class.new {
      include MemoryRecord
      memory_record table, attr_reader: true
    }
  end

  let(:instance) { Model.first }

  context 'Useful Class Methods' do
    it 'each' do
      assert Model.each
    end

    it 'keys' do
      assert_equal [:_key0, :_key1], Model.keys
    end

    it 'values' do
      assert_equal Model.each.to_a, Model.values
    end
  end

  context 'Subscript access to class' do
    it 'When code and key are automatically waved' do
      assert_equal 'A', Model[0].name
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
      instance[:name].should == 'A'
      instance[:xxxx].should == nil
    end
  end

  context 'to_s' do
    it do
      instance.to_s.should == 'A'
    end
  end

  context 'instance accessor' do
    it do
      assert instance.attributes
      assert instance.key
      assert instance.code
    end
  end

  context 'Re-set' do
    before do
      @model = __define [{key: :a}]
      @model.memory_record_reset [{key: :b}, {key: :c}]
    end
    it 'changed' do
      assert_equal [:b, :c], @model.keys
      assert_equal [0, 1], @model.codes
    end
  end

  context 'Subtle specifications' do
    it 'When keys are specified as an array, they become symbols with underscores' do
      model = __define [{key: [:id, :desc]}]
      assert_equal [:id_desc], model.keys
    end

    it 'Name method is automatically defined if it is not defined' do
      model = __define []
      assert_equal true, model.instance_methods.include?(:name)
    end
  end

  it 'Japanese can be used for key' do
    model = __define [{key: 'あ'}]
    assert model['あ']
  end

  it 'When you define code and keys yourself' do
    assert_equal 'A', Legacy[10].name
  end

  it 'We do not freeze values because memoization becomes impossible' do
    Model.first.name.upcase!
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
      assert_equal 'xy', Model2.first.var
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
      assert_equal 1, Model3.first.a
      assert_equal nil, Model3.first.b
    end
  end

  describe 'Do not duplicate key and code' do
    it do
      expect { Model.memory_record_reset([{key: :a}, {key: :a}]) }.to raise_error(ArgumentError)
      expect { Model.memory_record_reset([{code: 0}, {code: 0}]) }.to raise_error(ArgumentError)
    end
  end

  describe 'Human_attribute_name can not be used in anonymous class' do
    let(:model) { __define [{foo: 1}] }

    it 'It does not cause an error' do
      model.first.name.should == nil
    end
  end
end
