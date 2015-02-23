require 'simplecov'

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start

require 'cot'
require 'rspec'
require 'rspec/its'

require 'timeout'

RSpec.configure do |config|
  config.color = true
  config.formatter = 'documentation'
  # Add a timeout so mutant can't create infinite loops
  config.around do |example|
    Timeout.timeout(5) do
      example.run
    end
  end
end
