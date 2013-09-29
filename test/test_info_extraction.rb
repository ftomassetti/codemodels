require 'test_helper'

class MyDummyLanguageSpecificLogic

	def terms_containing_value?(value)
		return true  if ["ciao_come_stai","ciao_come"].include?(value) 
		return false if ["@@@","123.45"].include?(value) 
		raise "Error! invoked with #{value}"
	end

	def to_words(value)
		case value
		when 'ciao_come_stai'
			['ciao','come','stai']
		when 'ciao_come'
			['ciao','come']			
		else
			raise "Error! invoked with #{value}"
		end
	end

	def concat(a,b)
		"#{a}_#{b}"
	end

end

class MyMetaClass < RGen::MetamodelBuilder::MMBase
	has_many_attr 'a',String
	has_many_attr 'b',Float
end

class TestInfoExtaction < Test::Unit::TestCase

include CodeModels::InfoExtraction

def test_breaker_void_context
	tb = TermsBreaker.new(MyDummyLanguageSpecificLogic.new)
	assert_equal ["ciao","come","stai"],tb.terms_in_value("ciao_come_stai")
end

def test_breaker_with_frequent_word
	ctx = MyMetaClass.new
	ctx.addA 'ciao_come'
	tb = TermsBreaker.from_context(MyDummyLanguageSpecificLogic.new,ctx)
	assert_equal ["ciao_come","stai"],tb.terms_in_value("ciao_come_stai")
end

def test_empty_values_map
	ctx = MyMetaClass.new
	assert_equal({},ctx.values_map)
end

def test_simple_values_map
	ctx = MyMetaClass.new
	ctx.addA 'ciao_come'
	ctx.addA '@@@'
	ctx.addB 123.45
	assert_equal({'ciao_come'=>1,'@@@'=>1,123.45=>1},ctx.values_map)
end

def test_empty_terms_map
	n = MyMetaClass.new
	lsl = MyDummyLanguageSpecificLogic.new
	tb = TermsBreaker.new lsl
	assert_equal({},n.terms_map(tb))
end

def test_simple_terms_map
	ctx = MyMetaClass.new	
	n = MyMetaClass.new
	n.addA 'ciao_come'
	n.addA '@@@'
	n.addB 123.45
	lsl = MyDummyLanguageSpecificLogic.new
	assert_equal({'ciao'=>1,'come'=>1,'@@@'=>1,'123.45'=>1},n.terms_map(lsl,ctx))
end

def test_terms_map_with_composition
	ctx = MyMetaClass.new	
	ctx.addA 'ciao_come'
	lsl = MyDummyLanguageSpecificLogic.new
	n = MyMetaClass.new
	n.addA 'ciao_come_stai'
	n.addA '@@@'
	n.addB 123.45
	assert_equal({'ciao_come'=>1,'stai'=>1,'@@@'=>1,'123.45'=>1},n.terms_map(lsl,ctx))
end

end