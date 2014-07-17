ENV['RAILS_ENV'] ||= 'test'

require 'cot'
require 'rspec'
require 'rspec/its'

RSpec.configure do |config|
  config.color = true
  config.formatter = 'documentation'
end
