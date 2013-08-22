# encoding: utf-8

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec') do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = '--tag ~broken'
end


task :default => :spec
task :test => :spec
