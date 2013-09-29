require 'simplecov'
SimpleCov.start do
	add_filter "/test/"	
end

require 'codemodels'
require 'test/unit'
require 'rgen/metamodel_builder'

include CodeModels
