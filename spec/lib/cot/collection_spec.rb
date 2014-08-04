require 'spec_helper'
class FakeDouble < Cot::Frame
  property :id
  property :foo
  property :fooy
end

describe Cot::Collection do
  context 'array like' do
    it 'should take an array of objects and store them in a hash' do
      obj1 = { id: 123, foo: :bar }
      obj2 = { id: 234, foo: :baz }
      collection = Cot::Collection.new FakeDouble, [obj1, obj2]
      expect(collection.length).to eq 2
    end

    it 'should respond to array methods' do
      obj1 = { id: 123, foo: :bar }
      obj2 = { id: 234, foo: :baz }
      collection = Cot::Collection.new FakeDouble, [obj1, obj2]

      # In theory we'd test more, but that's good enough for me
      expect(collection).to respond_to :[]
      expect(collection).to respond_to :first
      expect(collection).to respond_to :reverse
    end
  end

  context 'update members' do
    it 'updates members' do
      coll = Cot::Collection.new FakeDouble, [{ fooy: :bar }]
      expect(coll.length).to eq 1
      coll.update_members [{ id: 123, foo: :bar }]
      expect(coll.first.id).to eq 123
    end

    it 'removes members that are not in the payload' do
      coll = Cot::Collection.new FakeDouble, [{ fooy: :bar }, { asdf: :fdas }]
      expect(coll.length).to eq 2
      coll.update_members [{ id: 123, foo: :bar }]
      expect(coll.first.id).to eq 123
      expect(coll.length).to eq 1
    end
  end

  context 'changed?' do
    it 'returns true if one of the objects has changed' do
      coll = Cot::Collection.new FakeDouble, [{ fooy: :bar }]
      coll.first.fooy = 'baz'
      expect(coll.changed?).to be true
    end
    it 'return false if none of the objects have changed' do
      coll = Cot::Collection.new FakeDouble, [{ fooy: :bar }]
      expect(coll.changed?).to be false
    end
  end
end
