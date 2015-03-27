require 'spec_helper'
describe Cot::Enum do
  before :each do
    class TestObject < Cot::Frame
      enum :types do
        entry :first
        entry :third, value: 3
        entry :fourth
      end
    end
    @foo = TestObject.new
  end
  subject(:enum) { @foo.types }
  it 'defines methods for each entry' do
    expect(enum.first).to eq 1
    expect(enum.third).to eq 3
    expect(enum.fourth).to eq 4
  end

  it 'allows hash access' do
    expect(enum).to respond_to :[]
    expect(enum[:first]).to eq 1
    expect(enum[:third]).to eq 3
    expect(enum[:fourth]).to eq 4
  end

  it 'sets used keys and values' do
    expect(TestObject.types.used).to have_key 1
    expect(TestObject.types.used[1]).to eq :first
  end

  it 'does not allow duplicates' do
    expect do
      class TestObject < Cot::Frame
        enum :types do
          entry :first
          entry :first_again, value: 1
        end
      end
    end.to raise_error StandardError,
                       'first_again tried to set value 1, which is already used by first. Enum values are unique.'
  end

  context 'objext' do
    it 'sets the value starting at 1' do
      expect(@foo.types.first).to eq 1
    end

    it 'allows the value to be set' do
      expect(@foo.types.third).to eq 3
    end

    it 'increments after the next value' do
      expect(@foo.types.fourth).to eq 4
    end
  end

  context 'class' do
    it 'sets the value starting at 1' do
      expect(TestObject.types.first).to eq 1
    end

    it 'allows the value to be set' do
      expect(TestObject.types.third).to eq 3
    end

    it 'increments after the next value' do
      expect(TestObject.types.fourth).to eq 4
    end
  end
end
