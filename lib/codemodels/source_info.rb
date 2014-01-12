# encoding: utf-8

require 'rgen/metamodel_builder'
require 'codemodels/language'
require 'codemodels/position'
require 'codemodels/artifact'

module CodeModels

# Info which specify from which part of the code a node was
# obtained.
#
# Some methods can accept a scope to be :relative or :absolute.
# When a piece of code derives from some embedded snipped (e.g., a piece of JS in html file)
# the relative position is specified in respect to the snippet, while the absolute
# in respect to the containing file.
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

	# @param data is expected to be an hash with :line and :column
	def begin_point=(data)
		point = data_to_point(data)
		@position = SourcePosition.new unless @position
		@position.begin_point = point
	end

	# @param data is expected to be an hash with :line and :column
	def end_point=(data)
		point = data_to_point(data)
		@position = SourcePosition.new unless @position
		@position.end_point = point		
	end

	def begin_line(scope=:relative)
		position(scope).begin_point.line
	end

	def end_line(scope=:relative)
		position(scope).end_point.line
	end	

	def begin_column(scope=:relative)
		position(scope).begin_point.column
	end

	def end_column(flag=:relative)
		position(scope).end_point.column
	end

	def begin_point(scope=:relative)
		position(scope).begin_point
	end

	def end_point(scope=:relative)
		position(scope).end_point
	end

	def position(scope=:relative)
		value = if scope==:relative
			@position
		elsif scope==:absolute
			absolute_position
		else
			raise "unvalid value #{flag}"
		end	
		raise "Returning not a position #{value} (#{value.class})" unless value.is_a?(SourcePosition)
		value
	end

	# Deprecated, use position(:absolute) instead
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

	# @param data is expected to be an hash with :line and :column
	def start_point=(data)
		@source = SourceInfo.new unless @source
		@source.start_point = data
	end

	# @param data is expected to be an hash with :line and :column
	def end_point=(data)
		@source = SourceInfo.new unless @source
		@source.end_point = data
	end
end

# Inside an host language snippet of other languages can be hosted
# For example Java code could contain in a string literal a sql statement
# or an Html file can contain CSS or Javascript code.
# In those cases an AST is inserted inside the AST of the host language.
module ForeignAstExtensions

	attr_accessor :foreign_container

	# The name is to maintain similarity with RGen (so we used camelcase instead of underscore)
	def addForeign_asts(foreign_ast)
		foreign_asts << foreign_ast
		foreign_ast.foreign_container = self
	end

	def foreign_asts
		@foreign_asts=[] unless @foreign_asts
		@foreign_asts
	end
end

# Deprecated
module HostPositionExtensions

	# Deprecated
	def absolute_position
		puts "HostPositionExtensions is DEPRECATED"
		artifact = source.artifact
		artifact.absolute_position(source.position)
	end

end

end