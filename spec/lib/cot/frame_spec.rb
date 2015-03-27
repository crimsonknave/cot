require 'spec_helper'
describe Cot::Frame do
  before :each do
    class TestObject < Cot::Frame
      property :foo, from: :bar, searchable: true
      property :id
      property :only, searchable: true
      search_property :john, from: :crichton
      search_property :pilot
    end
    @foo = TestObject.new(bar: 'this will be foo', id: 5, only: 3)
  end
  subject { @foo }
  its(:to_json) { should be_kind_of String }
  its(:id) { should eq 5 }
  its(:foo) { should eq 'this will be foo' }

  it 'primary key defaults to id' do
    expect(@foo.exists?).to be 5
  end

  context 'serializable_hash' do
    its(:serializable_hash) { should be_kind_of Hash }
    it 'has two keys' do
      expect(subject.serializable_hash.size).to eq 3
    end

    it 'should accept an option hash' do
      expect do
        subject.serializable_hash(only: :foo)
      end.to_not raise_error
    end

    it 'does not require an option hash' do
      expect do
        subject.serializable_hash
      end.to_not raise_error
    end

    context 'only option' do
      it 'should return properties specified' do
        expect(subject.serializable_hash(only: :foo).size).to eq 1
        expect(subject.serializable_hash(only: :foo)[:bar]).to eq 'this will be foo'
        expect(subject.serializable_hash(only: [:foo, :id]).size).to eq 2
        expect(subject.serializable_hash(only: 'foo').size).to eq 1
        expect(subject.serializable_hash(only: 'foo')[:bar]).to eq 'this will be foo'
        expect(subject.serializable_hash(only: :blah).size).to eq 0
      end
    end

    context 'except option' do
      it 'should not return properties specified' do
        expect(subject.serializable_hash(except: :foo).size).to eq 2
        expect(subject.serializable_hash(except: :foo)[:id]).to eq 5
        expect(subject.serializable_hash(except: [:foo, :id]).size).to eq 1
        expect(subject.serializable_hash(except: 'foo').size).to eq 2
        expect(subject.serializable_hash(except: 'foo')[:id]).to eq 5
      end
    end
  end

  context 'valid?' do
    it 'returns true if there are no errors' do
      expect(@foo).to receive(:errors).and_return []
      expect(@foo.valid?).to be true
    end

    it 'returns false if there is an error' do
      expect(@foo).to receive(:errors).and_return [1]
      expect(@foo.valid?).to be false
    end
  end

  context 'exists?' do
    it 'is true if id is present' do
      expect(@foo.exists?).to be_truthy
    end

    it 'is false if id is not present' do
      foo = TestObject.new(foo: 5)
      expect(foo.exists?).to be_falsey
    end
  end
  context 'defined_properties' do
    it 'includes foo' do
      expect(@foo.defined_properties).to include :foo
    end

    it 'is an array' do
      expect(@foo.defined_properties).to be_kind_of Array
    end

    it 'defaults to []' do
      class EmptyObject < Cot::Frame
      end
      foo = EmptyObject.new
      expect(foo.defined_properties).to eq []
    end
  end

  context 'value_blocks' do
    it 'defaults to {}' do
      class EmptyObject < Cot::Frame
      end
      foo = EmptyObject.new
      expect(foo.value_blocks).to eq({})
    end

    it 'has nil for no values' do
      expect(@foo.value_blocks).to eq(foo: nil, id: nil, only: nil)
    end
  end

  context 'missing_blocks' do
    it 'defaults to {}' do
      class EmptyObject < Cot::Frame
      end
      foo = EmptyObject.new
      expect(foo.missing_blocks).to eq({})
    end

    it 'has nil for no values' do
      expect(@foo.missing_blocks).to eq(foo: nil, id: nil, only: nil)
    end
  end

  context 'properties_mapping' do
    it 'defaults to {}' do
      class EmptyObject < Cot::Frame
      end
      foo = EmptyObject.new
      expect(foo.properties_mapping).to eq({})
    end
    it 'does not set if there is no from' do
      expect(@foo.properties_mapping).to_not have_key nil
    end

    it 'has bar => foo' do
      expect(@foo.properties_mapping).to have_key :bar
      expect(@foo.properties_mapping[:bar]).to eq :foo
    end
  end
  context 'inverted_properties_mapping' do
    it 'has foo => bar' do
      expect(@foo.inverted_properties_mapping).to have_key :foo
      expect(@foo.inverted_properties_mapping[:foo]).to eq :bar
    end
  end
  context 'search_mappings' do
    it 'has john => crichton' do
      expect(@foo.search_mappings).to have_key :john
      expect(@foo.search_mappings[:john]).to eq :crichton
    end
  end
  context 'inverted_search_mappings' do
    it 'has crichton => john' do
      expect(@foo.inverted_search_mappings).to have_key :crichton
      expect(@foo.inverted_search_mappings[:crichton]).to eq :john
    end
  end
  context 'search_property' do
    it 'adds to search_mappings' do
      expect(TestObject.search_mappings).to have_key :john
      expect(TestObject.search_mappings[:john]).to be :crichton
      expect(TestObject.search_mappings).to have_key :pilot
      expect(TestObject.search_mappings[:pilot]).to be :pilot
    end
  end
  context 'property' do
    it 'adds to mappings' do
      expect(TestObject.mappings).to have_key :bar
      expect(TestObject.mappings[:bar]).to be :foo
    end

    it 'adds to search properties when searchable is true' do
      expect(TestObject.search_mappings).to have_key :only
      expect(TestObject.search_mappings[:only]).to be :only
      expect(TestObject.search_mappings).to have_key :foo
      expect(TestObject.search_mappings[:foo]).to be :bar
    end

    it 'does not add to search mappings if not searchable' do
      expect(TestObject.search_mappings).to_not have_key :id
    end

    it 'works for strings and symbols' do
      foo1 = TestObject.new(bar: 'this will be foo', 'id' => 1)
      foo2 = TestObject.new(bar: 'this will be foo', id: 2)
      expect(foo1.id).to eq 1
      expect(foo2.id).to eq 2
    end

    it 'creates accessor methods' do
      foo = TestObject.new
      expect(foo).to respond_to :foo
      expect(foo).to respond_to :foo=
    end

    it 'adds to attr_methods' do
      expect(TestObject.attr_methods).to include(:foo)
    end

    it 'accessor methods uses []' do
      foo = TestObject.new
      expect(foo).to receive('[]').once.and_return 'this is foo'
      expect(foo.foo).to eq 'this is foo'
    end

    context 'passing a block' do
      before :each do
        class Foo
          attr_reader :params
          def initialize(params)
            @params = params
          end
        end
        class TestObject < Cot::Frame
          property :my_id, from: :key, primary: true
          property :foo, from: :bar
          property :blank do
            missing do
              "this was blank #{my_id}"
            end
          end
          property :thing do
            from :stuff
            searchable true
            value do |params|
              Foo.new params.merge passed: my_id
            end
          end
        end
        @foo = TestObject.new(stuff: { key: 'this will be in foo' }, key: 42)
      end

      it 'adds to mappings' do
        expect(TestObject.mappings).to have_key :stuff
        expect(TestObject.mappings[:stuff]).to be :thing
      end

      it 'stores searchable' do
        expect(TestObject.search_mappings).to have_key :thing
        expect(TestObject.search_mappings[:thing]).to be :stuff
      end

      context 'missing' do
        it 'does not call the block if the value is provided' do
          foo = TestObject.new(blank: 'blank')
          expect(foo.blank).to eq 'blank'
        end

        it 'does not set the block if missing is false' do
          foo = TestObject.new(blank: 'blank')
          expect(foo.foo).to be_nil
        end

        it 'calls the value if there is a block' do
          expect(@foo.blank).to eq 'this was blank 42'
        end

        it 'returns nil if there is no block' do
          expect(@foo.id).to be_nil
        end
      end

      it 'sets the primary key' do
        expect(@foo.exists?).to be 42
      end

      it 'sets the value' do
        expect(@foo.thing).to be_kind_of Foo
        expect(@foo.thing.params[:passed]).to eq 42
      end

      context '[]' do
        it 'accesses an unmapped key' do
          expect(@foo[:blank]).to eq 'this was blank 42'
        end

        it 'accesses a mapped key' do
          expect(@foo[:my_id]).to eq 42
        end
      end

      context '[]=' do
        it 'sets the value block' do
          bar = TestObject.new(key: 42)
          bar.thing = { key: 'this will be in foo' }
          expect(bar.thing).to be_kind_of Foo
          expect(bar.thing.params[:passed]).to eq 42
          expect(bar[:stuff]).to be_kind_of Foo
          expect(bar[:thing]).to be_kind_of Foo
        end

        it 'notifys that the field will change if the value is different' do
          bar = TestObject.new(key: 42, foo: 'thing')
          expect(bar).to receive(:foo_will_change!).and_return true
          bar.foo = 'baz'
        end

        it 'does not notify that the field will change if the value is the same' do
          bar = TestObject.new(key: 42, foo: 'baz')
          expect(bar).to_not receive(:foo_will_change!)
          bar.foo = 'baz'
        end

        it 'sets the value if it is not a block' do
          bar = TestObject.new(key: 42)
          bar.foo = 'baz'
          expect(bar.foo).to eq 'baz'
          expect(bar[:bar]).to eq 'baz'
        end
      end
    end
  end

  context 'errors' do
    it 'has an errors property' do
      expect(@foo).to respond_to :errors
      expect(@foo.errors).to be_empty
    end
  end

  context 'errors=' do
    it 'sets errors' do
      @foo.errors = { status: 200 }
      expect(@foo.errors[:status]).to eq 200
    end
  end
end
