require 'test_helper'

class TestLanguage < Test::Unit::TestCase

include CodeModels

class MyLanguage < Language
	def initialize(my_parser)
		super('MyLanguage')
		@extensions << 'my1'
		@extensions << 'my2'
		@parser = my_parser
	end
end

class MyOtherLanguage < Language
	def initialize(my_parser)
		super('MyLanguage')
		@filenames << 'pippo'
		@parser = my_parser
	end
end


class MyParser
	attr_reader :invokations

	def initialize
		@invokations = []
	end

	def parse_file(path)
		@invokations << path
	end
end

def setup
	@my_language = MyLanguage.new(MyParser.new)
	2.times {CodeModels.register_language(@my_language)}
	@my_parser = CodeModels.registered_languages[0].parser
end

def test_my_language
	assert_equal 1,CodeModels.registered_languages.count
	l = CodeModels.registered_languages[0]
	assert_equal 'MyLanguage',l.name
	assert_equal ['my1','my2'],l.extensions
	assert l.parser.is_a?(MyParser)
end

def test_can_parse_extension?
	assert_equal true, @my_language.can_parse?('a/dir/pippo.my1')
	assert_equal false, @my_language.can_parse?('a/dir/pippo.else')
end

def test_can_parse_extension?
	@l = MyOtherLanguage.new('MyOtherLanguage')
	assert_equal true, @l.can_parse?('a/dir/pippo')
	assert_equal false, @l.can_parse?('a/dir/pluto')
end

def test_parse_file_registered_language
	CodeModels.parse_file('pippo.my1')
	assert_equal ['pippo.my1'],@my_parser.invokations
end

def test_parse_file_unregistered_language
	assert_raise NoLanguageRegisteredError do 
		CodeModels.parse_file('pippo.else')
	end
end

end