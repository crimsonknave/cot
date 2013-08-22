require 'spec_helper'
describe Cot::Frame do
  before :each do
    class TestObject < Cot::Frame
      property :foo, :from => :bar
      property :id
      search_property :john, :from => :crichton
    end
    @foo = TestObject.new(:bar => 'this will be foo', :id => 5)
  end
  subject { @foo }
  its(:to_json) { should be_kind_of String }
  its(:serializable_hash) { should be_kind_of Hash }
  its(:serializable_hash) { should have(2).keys }
  it 'should have more serialziable tests'
  its(:id) { should eq 5 }
  its(:foo) { should eq 'this will be foo' }

  context 'exists?' do
    it 'should be true if id is present' do
      @foo.exists?.should be_true
    end
    it 'should be false if id is not present' do
      foo = TestObject.new(:foo => 5)
      foo.exists?.should be_false
    end
  end
  context 'defined_properties' do
    it 'should include foo' do
      @foo.defined_properties.should include :foo
    end
    it 'should be an array' do
      @foo.defined_properties.should be_kind_of Array
    end
  end
  context 'properties_mapping' do
    it 'should have bar => foo' do
      @foo.properties_mapping.should have_key :bar
      @foo.properties_mapping[:bar].should eq :foo
    end
  end
  context 'inverted_properties_mapping' do
    it 'should have foo => bar' do
      @foo.inverted_properties_mapping.should have_key :foo
      @foo.inverted_properties_mapping[:foo].should eq :bar
    end
  end
  context 'search_mappings' do
    it 'should have john => crichton' do
      @foo.search_mappings.should have_key :john
      @foo.search_mappings[:john].should eq :crichton
    end
  end
  context 'inverted_search_mappings' do
    it 'should have crichton => john' do
      @foo.inverted_search_mappings.should have_key :crichton
      @foo.inverted_search_mappings[:crichton].should eq :john
    end
  end
  context 'search_property' do
    it 'should add to search_mappings' do
      TestObject.search_mappings.should have_key :john
      TestObject.search_mappings[:john].should be :crichton
    end
  end
  context 'property' do
    it 'should add to mappings' do
      TestObject.mappings.should have_key :bar
      TestObject.mappings[:bar].should be :foo
    end
    it 'should create accessor methods' do
      foo = TestObject.new
      foo.should respond_to :foo
      foo.should respond_to :foo=
    end

    it 'should add to attr_methods' do
      TestObject.attr_methods.should include(:foo)
    end

    it 'accessor methods should use []' do
      foo = TestObject.new
      foo.should_receive('[]').once.and_return 'this is foo'
      foo.foo.should eq 'this is foo'
    end
  end
end
