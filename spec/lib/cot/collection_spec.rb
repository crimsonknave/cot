require 'spec_helper'
class FakeDouble < Cot::Frame
  property :id
  property :foo
  property :fooy
end

describe Cot::Collection do
  let(:obj1) { FakeDouble.new id: 1, foo: :bar }
  let(:obj2) { FakeDouble.new id: 2, foo: :bar }
  subject(:collection) { Cot::Collection.new FakeDouble, [obj1, obj2] }

  context 'array like' do
    it 'should take an array of objects and store them in a hash' do
      expect(collection.length).to eq 2
    end

    it 'should respond to array methods' do
      # In theory we'd test more, but that's good enough for me
      expect(collection).to respond_to :[]
      expect(collection).to respond_to :first
      expect(collection).to respond_to :reverse
    end
  end

  context 'serializable_hash' do
    it 'is an array' do
      expect(collection.serializable_hash).to be_kind_of Array
    end

    it 'has hash members' do
      expect(collection.serializable_hash.first).to be_kind_of Hash
    end
  end

  context 'to_json' do
    it 'returns a string' do
      expect(collection.to_json).to be_kind_of String
    end

    it 'is parseable json' do
      expect(JSON.parse(collection.to_json)).to be_kind_of Array
    end
  end

  context 'exists?' do
    it 'returns true if all the objects exist' do
      expect(obj1).to receive(:exists?).and_return true
      expect(obj2).to receive(:exists?).and_return true
      expect(collection.exists?).to be true
    end

    it 'returns false if any of the objects do not exist' do
      expect(obj1).to receive(:exists?).and_return true
      expect(obj2).to receive(:exists?).and_return false
      expect(collection.exists?).to be false
    end
  end

  context 'errors' do
    it 'is empty if there are no errors' do
      expect(collection.errors).to be_empty
    end

    it 'collates the errors of the contained objects' do
      obj2.errors = { status: 400 }
      expect(collection.errors.size).to be 1
      expect(collection.errors[2]).to have_key :status
    end
  end

  context 'initialize' do
    context 'when passing a class' do
      context 'with options' do
        it 'takes an optional sub_key option to pull the object out of the payload' do
          coll = Cot::Collection.new FakeDouble,
                                     [{ inner: { fooy: :bar } }, { inner: { asdf: :fdas } }],
                                     sub_key: :inner
          expect(coll.first).to be_kind_of FakeDouble
          expect(coll.first.fooy).to eq :bar
        end

        it 'takes an optional default_attributes option to add set attributes in every object.' do
          coll = Cot::Collection.new FakeDouble, [{ fooy: :bar }, { asdf: :fdas }], default_attributes: { foo: :baz }
          expect(coll).to all be_kind_of FakeDouble
          expect(coll.map(&:foo).uniq).to eq [:baz]
        end

        it 'support a legacy optional sub_key parameter to pull the object out of the payload' do
          coll = Cot::Collection.new FakeDouble, [{ inner: { fooy: :bar } }, { inner: { asdf: :fdas } }], :inner
          expect(coll.first).to be_kind_of FakeDouble
          expect(coll.first.fooy).to eq :bar
        end
      end

      context 'without options' do
        it 'does not process the objects if they are already the correct class' do
          coll = Cot::Collection.new FakeDouble, [FakeDouble.new(fooy: :bar), FakeDouble.new(asdf: :fdas)]
          expect(coll.first).to be_kind_of FakeDouble
        end

        it 'creates new instances of the passed klass if the objects are not already the class' do
          coll = Cot::Collection.new FakeDouble, [{ fooy: :bar }, { asdf: :fdas }]
          expect(coll.first).to be_kind_of FakeDouble
        end
      end
    end

    context 'when not passing a class' do
      before :each do
        class MyCollection < Cot::Collection
          collected_class FakeDouble
        end
      end

      context 'with options' do
        it 'takes an optional sub_key option to pull the object out of the payload' do
          coll = MyCollection.new [{ inner: { fooy: :bar } }, { inner: { asdf: :fdas } }], sub_key: :inner
          expect(coll.first).to be_kind_of FakeDouble
          expect(coll.first.fooy).to eq :bar
        end

        it 'takes an optional default_attributes option to add set attributes in every object.' do
          coll = MyCollection.new [{ fooy: :bar }, { asdf: :fdas }], default_attributes: { foo: :baz }
          expect(coll).to all be_kind_of FakeDouble
          expect(coll.map(&:foo).uniq).to eq [:baz]
        end
      end

      context 'options using dsl' do
        it 'subkey works' do
          class MyCollection
            sub_key :inner
          end

          coll = MyCollection.new [{ inner: { fooy: :bar } }, { inner: { asdf: :fdas } }]
          expect(coll.first).to be_kind_of FakeDouble
          expect(coll.first.fooy).to eq :bar
        end

        it 'takes an optional default_attributes option to add set attributes in every object.' do
          class MyCollection
            default_attributes foo: :baz
          end

          coll = MyCollection.new [{ fooy: :bar }, { asdf: :fdas }]
          expect(coll).to all be_kind_of FakeDouble
          expect(coll.map(&:foo).uniq).to eq [:baz]
        end
      end

      context 'without options' do
        it 'does not process the objects if they are already the correct class' do
          coll = Cot::Collection.new [FakeDouble.new(fooy: :bar), FakeDouble.new(asdf: :fdas)]
          expect(coll.first).to be_kind_of FakeDouble
        end

        it 'creates new instances of the passed klass if the objects are not already the class' do
          coll = Cot::Collection.new [{ fooy: :bar }, { asdf: :fdas }]
          expect(coll.first).to be_kind_of FakeDouble
        end
      end
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
