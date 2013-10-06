require 'rgen/metamodel_builder'
require 'codemodels/source_info'
require 'codemodels/navigation'

module CodeModels

# All AST nodes built with CodeModels should derive from this one
class CodeModelsAstNode < RGen::MetamodelBuilder::MMBase
	include SourceInfoExtensions
	include ForeignAstExtensions
	include HostPositionExtensions
	include NavigationExtensions
end

end