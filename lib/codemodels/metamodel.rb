require 'rgen/metamodel_builder'
require 'codemodels/language'

module CodeModels

class AbstractArtifact

	def point_to_absolute(point)
		offset = host_artifact.absolute_start
		p = SourcePoint.new
		p.line   = point.line  +offset.line-1
		p.column = point.column
		p.colum  += offset.column-1 if point.line==1
		p
	end

	def position_to_absolute(position)
		pos = SourcePosition.new
		pos.start_point = point_to_absolute(position.start_point)
		pos.end_point = point_to_absolute(position.end_point)
		pos
	end

end

class EmbeddedArtifact < AbstractArtifact
	attr_accessor :host_artifact
	attr_accessor :position_in_host

	def absolute_start
		p = host_artifact.absolute_start
		p.line   += position_in_host.begin_point.line
		p.column += position_in_host.begin_point.column
		p
	end

end

class FileArtifact < AbstractArtifact
	attr_accessor :filename

	def absolute_start
		sp = SourcePoint.new
		sp.line   = 1
		sp.column = 1
		sp
	end
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

	def set_start_point(data)
		point = data_to_point(data)
		position = SourcePosition.new unless position
		position.start_point = point
	end

	def set_end_point(data)
		point = data_to_point(data)
		position = SourcePosition.new unless position
		position.end_point = point		
	end

	private

	def data_to_point(data)
		if data.is_a? Hash
			point = SourcePoint.new
			point.line   = data[:line]
			point.column = data[:column]
		elsif data.is_a? SourcePoint
			point = data
		else
			raise "Expected Hash or SourcePoint"
		end
		point
	end

end	

# This extension give all the information about the source
# from which the node was derived
module SourceInfoExtensions
	attr_accessor :language
	attr_accessor :source	

	def set_start_point(data)
		source = SourceInfo.new unless source
		source.set_start_point(data)
	end

	def set_end_point(data)
		source = SourceInfo.new unless source
		source.set_end_point(data)		
	end
end

# Inside an host language snippet of other languages can be hosted
# For example Java code could contain in a string literal a sql statement
# or an Html file can contain CSS or Javascript code.
# In those cases an AST is inserted inside the AST of the host language.
module ForeignAstExtensions
	attr_accessor :foreign_asts
end

module HostPositionExtensions

	def absolute_position
		artifact = source.artifact
		artifact.absolute_position(source.position)
	end

end

# All AST nodes built with CodeModels should derive from this one
class CodeModelsAstNode < RGen::MetamodelBuilder::MMBase
	include SourceInfoExtensions
	include ForeignAstExtensions
	include HostPositionExtensions
end

end