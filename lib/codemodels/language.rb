# encoding: utf-8
module CodeModels

@@languages = []

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

# It avoids multiple registration of the same class
def self.register_language(language)
	return if @@languages.find {|l| l.is_a?(language.class)}
	@@languages << language
end

def self.registered_languages
	@@languages
end

class NoLanguageRegistered < Exception
	attr_reader :path

	def initialize(path)
		@path = path
	end
end

def self.parse_file(path)
	l = @@languages.find {|l| l.can_parse?(path) }
	raise NoLanguageRegistered.new(path) unless l
	l.parser.parse_file(path)
end

end