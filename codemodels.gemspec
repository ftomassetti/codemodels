# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codemodels/version'

Gem::Specification.new do |s|
  s.platform    = 'java'
  s.name        = 'codemodels'
  s.version     = CodeModels::VERSION
  s.summary     = "Library to build models of code"
  s.description = "Library to build models of code of different languages in a uniform way."
  s.authors     = ["Federico Tomassetti"]
  s.email       = 'f.tomassetti@gmail.com'
  s.homepage    = 'https://github.com/ftomassetti/codemodels'
  s.license     = "Apache v2"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'json',    '~> 1.8'
  s.add_dependency 'rgen',    '~> 0.6.6'
  s.add_dependency 'rgen_ext','0.0.2'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rubygems-tasks', '~> 0.2.4'
  s.add_development_dependency 'yard',           '~> 0.8.7'
end
