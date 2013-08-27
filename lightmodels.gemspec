Gem::Specification.new do |s|
  s.platform    = 'java'
  s.name        = 'lightmodels'
  s.version     = '0.1.2'
  s.date        = '2013-08-27'
  s.summary     = "Light format to store models"
  s.description = "Light format to store models. Mostly they are stored in Hash and Array."
  s.authors     = ["Federico Tomassetti"]
  s.email       = 'f.tomassetti@gmail.com'
  s.homepage    = 'http://federico-tomassetti.it'
  s.files       = [
     "lib/lightmodels.rb"
  ]
  curr_dir = File.dirname(__FILE__)
  Dir[curr_dir+"/lib/lightmodels/*.rb"].each do |rb|
    s.files << rb
  end

  s.add_dependency('emf_jruby')
  s.add_dependency('json')
end