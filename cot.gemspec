# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'cot/version'

Gem::Specification.new do |s|
  s.name = 'cot'
  s.version = Cot::VERSION

  s.authors = ['Joseph Henrich']
  s.email = ['crimsonknave@gmail.com']
  s.homepage = 'http://github.com/crimsonknave/cot'
  s.summary = 'Simplifies creating models for rest based resources'
  s.description = 'Simplifies creating models for rest based resources'
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'activemodel'
  s.add_development_dependency 'shoulda', '>= 0'
  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'rspec', '>= 0'
  s.add_development_dependency 'rspec-its', '>= 0'
  s.add_development_dependency 'rubocop', '>= 0.26.0'
  s.add_development_dependency 'simplecov', '>= 0'
end
