require 'spec_helper'
class FakeDouble
  def initialize(params)
    params.each do |key, value|
      define_singleton_method key do
        value
      end
    end
  end
end
describe Cot::Collection do
  context 'hash like' do
    it 'should take an array of objects and store them in a hash' do
      obj1 = { id: 123, foo: :bar }
      obj2 = { id: 234, foo: :baz }
      collection = Cot::Collection.new FakeDouble, [obj1, obj2]
      expect(collection.values.length).to eq 2

    end
    it 'should respond to hash methods' do
      obj1 = { id: 123, foo: :bar }
      obj2 = { id: 234, foo: :baz }
      collection = Cot::Collection.new FakeDouble, [obj1, obj2]

      # In theory we'd test more, but that's good enough for me
      expect(collection).to respond_to :keys
      expect(collection).to respond_to :each_pair
      expect(collection).to respond_to :invert
    end
  end
  context '[]=' do
  end
  context 'changed' do
    it 'returns true if one of the objects has changed'
    it 'return false if none of the objects have changed'
  end
end
