require 'rgen/metamodel_builder'
require 'codemodels/language'

module CodeModels

class AbstractArtifact

	def point_to_absolute(point)
		offset = absolute_start
		p = SourcePoint.new
		p.line   = point.line  + offset.line - 1
		p.column = point.column
		p.column  += offset.column-1 if point.line==1
		p
	end

	def position_to_absolute(position)
		pos = SourcePosition.new
		pos.begin_point = point_to_absolute(position.begin_point)
		pos.end_point = point_to_absolute(position.end_point)
		pos
	end

end

class EmbeddedArtifact < AbstractArtifact
	attr_accessor :host_artifact
	attr_accessor :position_in_host

	def absolute_start
		p = host_artifact.absolute_start
		p.line   += position_in_host.begin_point.line-1
		if position_in_host.begin_point.line==1			
			# if I am on the first line of my "host", its column
			# matters because there are not newlines to reset the column
			# counter
			p.column += position_in_host.begin_point.column-1 
		else
			p.column = position_in_host.begin_point.column
		end
		p
	end

	def to_s
		"Embedded in (#{@host_artifact.to_s}) at #{position_in_host}"
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

	def to_s
		"File #{filename}"
	end
end

class SourcePoint
	attr_accessor :line, :column

	def initialize(line=nil,column=nil)
		@line   = line
		@column = column
	end

	def eql?(other)
		other.line==line && other.column==column
	end

	def ==(other)
		self.eql?(other)
	end

	def to_s
		"Line #{@line}, Col #{@column}"
	end
end

class SourcePosition
	attr_accessor :begin_point, :end_point

	def initialize(begin_point=nil,end_point=nil)
		@begin_point = begin_point
		@end_point = end_point
	end

	def begin_line=(line)
		@begin_point=SourcePoint.new unless @begin_point
		@begin_point.line = line
	end

	def begin_column=(column)
		@begin_point=SourcePoint.new unless @begin_point
		@begin_point.column = column
	end

	def eql?(other)
		other.begin_point==begin_point && other.end_point==end_point
	end

	def ==(other)
		self.eql?(other)
	end

	def to_s
		"from #{@begin_point} to #{@end_point}"
	end
end

class SourceInfo
	attr_accessor :artifact
	attr_accessor :position

	def to_code
		raise "Unimplemented"
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

	def begin_line
		position.begin_point.line
	end

	def end_line
		position.end_point.line
	end	

	def absolute_position
		@artifact.position_to_absolute(@position)
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