require 'rgen/metamodel_builder'

module CodeModels

# Inside an host language snippet of other languages can be hosted
# For example Java code could contain in a string literal a sql statement
# or an Html file can contain CSS or Javascript code.
# In those cases an AST is inserted inside the AST of the host language.
# The "foreign AST" is inserted in a containment relationship named
# foreign_asts.
# This command insert the relation for the class, if it has not already.
def self.enable_foreign_asts(metaclass)
	return if has_foreign_asts?(metaclass)
	metaclass.contains_many_uni('foreign_asts', CodeModelsAstNode)	
	# We check because there is a strange behavior
	# in RGen...
	raise "the reference should be there!" unless has_foreign_asts?(metaclass)
end

private

def self.has_foreign_asts?(metaclass)
	return true if metaclass.instance_methods.include?(:foreign_asts)
	if metaclass.eContainer
		return has_foreign_asts(metaclass.eContainer)
	else
		return false
	end
end

end