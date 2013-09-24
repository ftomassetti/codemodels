module LightModels

@@languages = []

class Parser

	def parse_file(path)
		code = IO.read(path)
		parse_code(code)
	end

end

module LightModelsNode
	attr_accessor :source
	attr_accessor :language
end

class Position
	attr_accessor :line, :column
end

class SourceInfo
	attr_accessor :filename
	attr_accessor :begin_pos, :end_pos

	def to_code
		raise "Unimplemented"
	end

end

class Language
	attr_reader :name
	attr_reader :extensions
	attr_reader :parser

	def initialize(name)
		@name = name
		@extensions = []
	end	

	def can_parse?(path)
		extension = File.extname(path)
		extension=extension[1..-1] if extension.length>0		
		@extensions.include?(extension)
	end

end

def self.register_language(language)
	@@languages << language
end

def self.registered_languages
	@@languages
end

def self.parse_file(path)
	l = @@languages.find {|l| l.can_parse?(path) }
	raise "I don't know how to pars #{path}" unless l
	l.parser.parse_file(path)
end

end