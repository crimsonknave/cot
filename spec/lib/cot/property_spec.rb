require 'spec_helper'
describe Cot::Property do
  it 'can set the primary attribute' do
    prop = described_class.new
    expect(prop.primary?).to be_nil
    prop.primary
    expect(prop.primary?).to be true
  end
end
