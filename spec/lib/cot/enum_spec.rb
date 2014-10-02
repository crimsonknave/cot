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
end
