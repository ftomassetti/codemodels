require 'rgen/metamodel_builder'

module LightModels

def self.enable_foreign_asts(clazz)
	clazz.class_eval do
		contains_many_uni 'foreign_asts', LightModelsAstNode		
	end
end

end