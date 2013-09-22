require 'simplecov'
SimpleCov.start do
	add_filter "/test/"	
end

require 'lightmodels'
require 'test/unit'
require 'rgen/metamodel_builder'

include LightModels
