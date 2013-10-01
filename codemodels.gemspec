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

  s.add_dependency('json')
  s.add_dependency('rgen')

  s.add_development_dependency "bundler", "1.3.5"
  s.add_development_dependency "rake"  
  s.add_development_dependency "simplecov"
end
