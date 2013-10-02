require 'rgen/metamodel_builder'
require 'codemodels/language'

module CodeModels

class EmbeddedArtifact
	attr_accessor :host_artifact
	attr_accessor :position_in_host
end

class FileArtifact
	attr_accessor :filename
end

class SourcePoint
	attr_accessor :line, :column
end

class SourcePosition
	attr_accessor :begin_point, :end_point
end

class SourceInfo
	attr_accessor :artifact
	attr_accessor :position

	def to_code
		raise "Unimplemented"
	end

end	

# This extension give all the information about the source
# from which the node was derived
module SourceInfoExtensions
	attr_accessor :language
	attr_accessor :source	
end

# Inside an host language snippet of other languages can be hosted
# For example Java code could contain in a string literal a sql statement
# or an Html file can contain CSS or Javascript code.
# In those cases an AST is inserted inside the AST of the host language.
module ForeignAstExtensions
	attr_accessor :foreign_asts
end

# All AST nodes built with CodeModels should derive from this one
class CodeModelsAstNode < RGen::MetamodelBuilder::MMBase
	include SourceInfoExtensions
	include ForeignAstExtensions
end

end