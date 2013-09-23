require 'test_helper'

class TestLanguage < Test::Unit::TestCase

include LightModels

class MyLanguage < Language
	def initialize
		super('MyLanguage')
		@extensions << 'my1'
		@extensions << 'my2'
		@parser = 'p'
	end
end

def setup
	LightModels.register_language(MyLanguage.new)
end

def test_my_language
	assert_equal 1,LightModels.registered_languages.count
	l = LightModels.registered_languages[0]
	assert_equal 'MyLanguage',l.name
	assert_equal ['my1','my2'],l.extensions
	assert_equal 'p',l.parser
end

end