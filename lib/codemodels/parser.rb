require 'codemodels/monkey_patching'

module CodeModels

class Parser

	attr_reader :internal_encoding

	def initialize(internal_encoding='UTF-8')
		@internal_encoding = internal_encoding
	end

	def parse_file(path,file_encoding=nil)
		file_encoding = internal_encoding unless file_encoding
		code = IO.read(path,{ :encoding => file_encoding, :mode => 'rb'})
		code = code.encode(internal_encoding)
		parse_code(code)
	end

	def parse_code(code)
		raise 'Wrong encoding' unless code.encoding.name==internal_encoding
		internal_parse_code(code)
	end

end

class ParsingError < Exception
 	attr_reader :node
 	attr_reader :line

 	def initialize(node,msg,line=nil)
 		@node = node
 		@msg = msg
 		@line = line
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