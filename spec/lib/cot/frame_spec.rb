require 'spec_helper'
describe Cot::Frame do
  before :each do
    class TestObject < Cot::Frame
      property :foo, from: :bar
      property :id
      search_property :john, from: :crichton
    end
    @foo = TestObject.new(bar: 'this will be foo', id: 5)
  end
  subject { @foo }
  its(:to_json) { should be_kind_of String }
  it 'needs more serialziable tests'
  its(:id) { should eq 5 }
  its(:foo) { should eq 'this will be foo' }

  context 'serializable_hash' do
    its(:serializable_hash) { should be_kind_of Hash }
    it 'has two keys' do
      expect(subject.serializable_hash.size).to eq 2
    end

    it 'should accept an option hash' do
      expect do
        subject.serializable_hash(only: :foo)
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
        expect(subject.serializable_hash(except: :foo).size).to eq 1
        expect(subject.serializable_hash(except: :foo)[:id]).to eq 5
        expect(subject.serializable_hash(except: [:foo, :id]).size).to eq 0
        expect(subject.serializable_hash(except: 'foo').size).to eq 1
        expect(subject.serializable_hash(except: 'foo')[:id]).to eq 5
      end
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
  end
  context 'properties_mapping' do
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
    end
  end
  context 'property' do
    it 'adds to mappings' do
      expect(TestObject.mappings).to have_key :bar
      expect(TestObject.mappings[:bar]).to be :foo
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
  context 'enum' do
    it 'is not implemented' do
      expect do
        class TestObject < Cot::Frame
          enum 'asdf'
        end
      end.to raise_exception StandardError
    end
  end
end
