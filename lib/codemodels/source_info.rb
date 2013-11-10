# encoding: utf-8

require 'rgen/metamodel_builder'
require 'codemodels/language'
require 'codemodels/position'
require 'codemodels/artifact'

module CodeModels

class SourceInfo
	attr_accessor :artifact
	attr_accessor :position

	def artifact(scope=:relative)
		case scope
		when :relative
			@artifact
		when :absolute
			@artifact.final_host
		else
			raise "unvalid scope"
		end
	end

	def code
		position(:absolute).get_string(artifact.final_host.code)
	end

	def position=(value)
		raise "Not assignable #{value} (#{value.class})" unless value.is_a?(SourcePosition)
		@position = value
	end

	def begin_point=(data)
		point = data_to_point(data)
		@position = SourcePosition.new unless @position
		@position.begin_point = point
	end

	def end_point=(data)
		point = data_to_point(data)
		@position = SourcePosition.new unless @position
		@position.end_point = point		
	end

	def begin_line(flag=:relative)
		position.begin_point.line
	end

	def end_line(flag=:relative)
		position(flag).end_point.line
	end	

	def begin_column(flag=:relative)
		position(flag).begin_point.column
	end

	def end_column(flag=:relative)
		position(flag).end_point.column
	end

	def begin_point(flag=:relative)
		position(flag).begin_point
	end

	def end_point(flag=:relative)
		position(flag).end_point
	end

	def position(flag=:relative)
		value = if flag==:relative
			@position
		elsif flag==:absolute
			absolute_position
		else
			raise "unvalid value #{flag}"
		end	
		raise "Returning not a position #{value} (#{value.class})" unless value.is_a?(SourcePosition)
		value
	end

	def absolute_position
		raise "#{self} is not placed in any artifact" unless @artifact
		@artifact.position_to_absolute(@position)
	end

	def embedded?
		@artifact.embedded?
	end

	def embedding_level
		@artifact.embedding_level
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
		@source = SourceInfo.new unless @source
		@source.set_start_point(data)
	end

	def set_end_point(data)
		@source = SourceInfo.new unless @source
		@source.set_end_point(data)		
	end
end

# Inside an host language snippet of other languages can be hosted
# For example Java code could contain in a string literal a sql statement
# or an Html file can contain CSS or Javascript code.
# In those cases an AST is inserted inside the AST of the host language.
module ForeignAstExtensions

	attr_accessor :foreign_container

	def addForeign_asts(foreign_ast)
		foreign_asts << foreign_ast
		foreign_ast.foreign_container = self
	end

	def foreign_asts
		@foreign_asts=[] unless @foreign_asts
		@foreign_asts
	end
end

module HostPositionExtensions

	def absolute_position
		artifact = source.artifact
		artifact.absolute_position(source.position)
	end

end


end