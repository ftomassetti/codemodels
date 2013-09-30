require 'codemodels/monkey_patching'

module CodeModels

class Parser

	def parse_file(path)
		parse_code(IO.read(path))
	end

end

class ParsingError < Exception
 	attr_reader :node
 	attr_reader :line

 	def initialize(node,msg,line=nil)
 		@node = node
 		@msg = msg
 		@line = lin
 	end

 	def to_s
 		"#{@msg}, start line: #{@line}"
 	end

end

class UnknownNodeType < ParsingError

 	def initialize(node,line=nil,node_type=nil,where=nil)
 		super(node,"UnknownNodeType: type=#{node_type} , where: #{where}")
 	end

end

end