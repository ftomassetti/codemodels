require 'rgen/metamodel_builder'
require 'rgen/ext'
require 'codemodels/source_info'
require 'codemodels/navigation'
require 'codemodels/info_extraction'
require 'codemodels/serialization'
require 'codemodels/comparison'

module CodeModels

# All AST nodes built with CodeModels should derive from this one
class CodeModelsAstNode < RGen::MetamodelBuilder::MMBase

	class << self
		include RGen::Ext::InstantiationExtensions
	end

	include SourceInfoExtensions
	include ForeignAstExtensions
	include HostPositionExtensions
	include NavigationExtensions
	include ComparisonModule
	include InfoExtraction::InfoExtractionFunctionalities
	include Serialization::SerializationFunctionalities
end

end