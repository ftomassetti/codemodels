require 'rgen/metamodel_builder'
require 'lightmodels/language'

module LightModels

# All nodes should derive from this one
class LightModelsAstNode < RGen::MetamodelBuilder::MMBase
	include LightModelsReflectionInfo
end

end