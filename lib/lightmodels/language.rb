module LightModels

@@languages = []

class Language
	attr_reader :name
	attr_reader :extensions
	attr_reader :parser

	def initialize(name)
		@name = name
		@extensions = []
	end

	def parse_file(path)
		code = IO.read(path)
		parse_code(code)
	end

end

def self.register_language(language)
	@@languages << language
end

def self.registered_languages
	@@languages
end

end