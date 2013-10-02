require 'rgen/metamodel_builder'

module CodeModels

def self.enable_foreign_asts(clazz)
	return if clazz.instance_methods.include?(:foreign_asts)
	clazz.contains_many_uni('foreign_asts', CodeModelsAstNode)	
end

end