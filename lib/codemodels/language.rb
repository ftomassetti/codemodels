require 'pathname'

# encoding: utf-8
module CodeModels

@@languages = []

class Language
	attr_reader :name
	attr_reader :filenames
	attr_reader :extensions
	attr_reader :parser

	def initialize(name)
		@name = name
		@extensions = []
		@filenames = []
	end	

	def can_parse?(path)
		simple_name = Pathname.new(path).basename.to_s
		extension = File.extname(path)
		extension=extension[1..-1] if extension.length>0		
		@extensions.include?(extension) || @filenames.include?(simple_name) 
	end

end

def self.unregister_all_languages
	@@languages = []
end

# It avoids multiple registration of the same class
def self.register_language(language)
	return if @@languages.find {|l| l.is_a?(language.class)}
	@@languages << language
end

def self.registered_languages
	@@languages
end

class NoLanguageRegisteredError < StandardError
	attr_reader :description

	# @param description a description of the thing being parsed or the mechanism
	#                    through which a language was searched
	def initialize(description)
		super("No language registered to parse #{description}")
		@description = description
	end

end

def self.parse_file(path)
	l = @@languages.find {|l| l.can_parse?(path) }
	raise NoLanguageRegisteredError.new("language for path #{path}") unless l
	l.parser.parse_file(path)
end

def self.parse_string(code,language_name)
	language_name = language_name.to_s if language_name.is_a?(Symbol)
	l = @@languages.find {|l| l.name==language_name }
	raise NoLanguageRegisteredError.new("language with name '#{language_name}'") unless l
	l.parser.parse_string(code)
end

end