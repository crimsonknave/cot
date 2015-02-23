# encoding: utf-8

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec') do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = '--tag ~broken'
end

require 'rubocop'
if defined? RuboCop
  desc 'run rubocop'
  task :rubocop do
    puts `rubocop`
  end
end

task default: [:spec, :rubocop]
task test: :spec

require 'mutant'
desc 'Run mutation tests using mutant'
task :mutant do
  result = Mutant::CLI.run(%w[-Ilib -rcot --use rspec Cot*])
  fail unless result == Mutant::CLI::EXIT_SUCCESS
end
