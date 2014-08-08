require 'simplecov'

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start

require 'cot'
require 'rspec'
require 'rspec/its'

RSpec.configure do |config|
  config.color = true
  config.formatter = 'documentation'
end
