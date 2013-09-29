require 'rgen/metamodel_builder'
require 'codemodels/language'

module CodeModels

# All nodes should derive from this one
class CodeModelsAstNode < RGen::MetamodelBuilder::MMBase
	include CodeModelsReflectionInfo
end

end