require 'spec_helper'

class Model
  include MemoryRecord
  memory_record [
    {name: "A"},
    {name: "B"},
  ], attr_reader: :name
end

class Legacy
  include MemoryRecord
  memory_record [
    {code: 10, key: :a, name: "A"},
    {code: 20, key: :b, name: "B"},
  ], attr_reader: :name
end

RSpec.describe MemoryRecord do
  def __define(table)
    Class.new {
      include MemoryRecord
      memory_record table, attr_reader_auto: true
    }
  end

  let(:instance) { Model.first }

  context "便利クラスメソッド" do
    it "each" do
      assert Model.each
    end

    it "keys" do
      assert_equal [:_key0, :_key1], Model.keys
    end

    it "values" do
      assert_equal Model.each.to_a, Model.values
    end
  end

  context "クラスに対しての添字アクセス" do
    it "コードもキーも自動で振る場合" do
      assert_equal "A", Model[0].name
    end

    it "対応するキーがなくなてもエラーにならない" do
      assert_nothing_raised { Model[:unknown] }
    end

    it "fetchの場合、対応するキーがなければエラーになる" do
      assert_raises { Model.fetch(:unknown) }
    end

    it "fetch_if" do
      assert_nothing_raised { Model.fetch_if(nil) }
    end
  end

  context "インスタンスに対しての添字アクセス" do
    it do
      instance[:name].should == "A"
      instance[:xxxx].should == nil
    end
  end

  context "to_s" do
    it do
      instance.to_s.should == "A"
    end
  end

  context "インスタンスのアクセサー" do
    it do
      assert instance.attributes
      assert instance.key
      assert instance.code
    end
  end

  context "再設定" do
    before do
      @model = __define [{key: :a}]
      @model.memory_record_list_set [{key: :b}, {key: :c}]
    end
    it "変更できている" do
      assert_equal [:b, :c], @model.keys
      assert_equal [0, 1], @model.codes
    end
  end

  context "微妙な仕様" do
    it "キーは配列で指定するとアンダーバー付きのシンボルになる" do
      model = __define [{key: [:id, :desc]}]
      assert_equal [:id_desc], model.keys
    end

    it "nameメソッドは定義されてなければ自動的に定義" do
      model = __define []
      assert_equal true, model.instance_methods.include?(:name)
    end
  end

  it "キーに日本語が使える" do
    model = __define [{key: "あ"}]
    assert model["あ"]
  end

  it "コードやキーは自分で定義する場合" do
    assert_equal "A", Legacy[10].name
  end

  it "メモ化が使えなくなるため値のfreezeはしない" do
    Model.first.name.upcase!
  end

  describe "super" do
    class Model2
      include MemoryRecord
      memory_record [
        {var: "x"},
      ], attr_reader: :var

      def var
        super + "y"
      end
    end

    it "メソッドは裏に定義されているのでsuperを使える" do
      assert_equal "xy", Model2.first.var
    end
  end

  describe "attr_reader_auto" do
    class Model3
      include MemoryRecord
      memory_record [
        {a: 1},
        {b: 2},
      ], attr_reader_auto: true
    end

    it "attr_reader => [:a, :b] を自動的に定義" do
      assert_equal 1, Model3.first.a
      assert_equal nil, Model3.first.b
    end
  end

  describe "key と code の重複はダメ" do
    it do
      expect { Model.memory_record_list_set([{key: :a}, {key: :a}]) }.to raise_error(ArgumentError)
      expect { Model.memory_record_list_set([{code: 0}, {code: 0}]) }.to raise_error(ArgumentError)
    end
  end

  describe "無名クラスで human_attribute_name は使えない" do
    let(:model) { __define [{foo: 1}] }

    it "エラーにならない " do
      model.first.name.should == nil
    end
  end
end
