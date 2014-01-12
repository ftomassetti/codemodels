# encoding: utf-8

require 'codemodels/monkey_patching'

module CodeModels

# A parser get code and produce an AST
#
# Sub-classes should provide internal_parse_artifact
class Parser

	DEFAULT_INTERNAL_ENCODING = 'UTF-8'

	# Internal encoding. 
	# Code is internally converted to this encoding.
	attr_reader :internal_encoding

	def initialize(internal_encoding=DEFAULT_INTERNAL_ENCODING)
		@internal_encoding = internal_encoding
		puts "WARN using an internal encoding different from the local encoding..." if "".encoding.name!=internal_encoding
		raise "The method internal_parse_artifact should be implemented" unless self.respond_to?(:internal_parse_artifact)
	end

	def parse_artifact(artifact)
		internal_parse_artifact(artifact)
	end

	# Parse the file by producing an artifact corresponding to the file
	def parse_file(path,file_encoding=nil)
		file_encoding = @internal_encoding unless file_encoding
		code = IO.read(path,{ :encoding => file_encoding, :mode => 'rb'})
		code = code.encode(@internal_encoding)
		artifact = FileArtifact.new(path,code)
		parse_artifact(artifact)
	end

	# Parse the file by producing an artifact corresponding to the string
	def parse_string(code)
		raise "Wrong encoding: it is #{code.encoding.name}, internally expected #{internal_encoding}" unless code.encoding.name==internal_encoding
		artifact = StringArtifact.new(code)
		parse_artifact(artifact)
	end

end

class ParsingError < StandardError
 	attr_reader :node
 	attr_reader :line
 	attr_reader :column

 	def initialize(node,msg,line=nil,column=nil)
 		super("Parsing error: #{msg}")
 		@node = node
 		@msg = msg
 		@line = line
 		@column = column
 		raise "If column is specified also line should be" if line==nil and column!=nil
 	end

 	def to_s
 		if @line and @column
 			"Parsing error: #{@msg}, node: #{node}, line: #{@line}, column: #{column}"
 		elsif @line
			"Parsing error: #{@msg}, node: #{node}, line: #{@line}"
		else
			"Parsing error: #{@msg}, node: #{node}"
		end
 	end

end

# Most CodeModels parser are actually
# wrapping another parser and adapting it
# to CodeModels. When they encounter a node type
# they do not know how to wrap this error is thrown.
#
# This is not just for java based parsers, so it should
# be not moved to codemodels-javaparserwrapper
class UnknownNodeType < ParsingError

	# @param node the node that can not be translated
	# @param node_type node that is not understood
	# @param where describe where the node was contained (artifact, line, column)
 	def initialize(node,line=nil,node_type=nil,where=nil)
 		super(node,"UnknownNodeType: type=#{node_type} , where: #{where}")
 	end

end

end