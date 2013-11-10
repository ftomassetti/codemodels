require 'codemodels/monkey_patching'

module CodeModels

class Parser

	attr_reader :internal_encoding

	def initialize(internal_encoding='UTF-8')
		@internal_encoding = internal_encoding
	end

	def parse_artifact(artifact)
		internal_parse_artifact(artifact)
	end

	def parse_file(path,file_encoding=nil)
		file_encoding = internal_encoding unless file_encoding
		code = IO.read(path,{ :encoding => file_encoding, :mode => 'rb'})
		code = code.encode(internal_encoding)
		artifact = FileArtifact.new(path,code)
		internal_parse_artifact(artifact)
	end

	# Deprecated: use parse_string
	def parse_code(code)
		parse_string(code)
	end

	def parse_string(code)
		raise 'Wrong encoding: it is #{code.encoding.name}, internally expected #{internal_encoding}' unless code.encoding.name==internal_encoding
		artifact = StringArtifact.new(code)
		internal_parse_artifact(artifact)
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

# Most CodeModels parser are actually
# wrapping another parser and adapting it
# to CodeModels. When they encounter a node type
# they do not know how to wrap this error is thrown.
# This is not just for java based parsers, so it should
# be not moved to codemodels-javaparserwrapper
class UnknownNodeType < ParsingError

 	def initialize(node,line=nil,node_type=nil,where=nil)
 		super(node,"UnknownNodeType: type=#{node_type} , where: #{where}")
 	end

end

end