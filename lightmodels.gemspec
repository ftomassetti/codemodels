# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lightmodels/version'

Gem::Specification.new do |s|
  s.platform    = 'java'
  s.name        = 'lightmodels'
  s.version     = LightModels::VERSION
  s.date        = '2013-08-27'
  s.summary     = "Light format to store models"
  s.description = "Light format to store models. Mostly they are stored in Hash and Array."
  s.authors     = ["Federico Tomassetti"]
  s.email       = 'f.tomassetti@gmail.com'
  s.homepage    = 'https://github.com/ftomassetti/lightmodels'
  s.license     = "APACHE2"

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