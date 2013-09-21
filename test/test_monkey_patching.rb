require 'test_helper'

module A
	module B
		module C
		end
	end
end

class TestMonkeyPatching < Test::Unit::TestCase

def test_module_simple_name
	assert_equal 'A',A.simple_name
	assert_equal 'B',A::B.simple_name
	assert_equal 'C',A::B::C.simple_name
end

def test_strig_remove_prefix
	assert_equal 'abc','123abc'.remove_prefix('123')
	assert_equal '','123'.remove_prefix('123')
end

def test_strig_remove_postfix
	assert_equal '123','123abc'.remove_postfix('abc')
	assert_equal '','123'.remove_postfix('123')
end

def test_proper_capitalize
	assert_equal 'CiaoMondo','ciaoMondo'.proper_capitalize
	assert_equal 'CiaoMondo','CiaoMondo'.proper_capitalize
end

def test_proper_uncapitalize
	assert_equal 'ciaoMondo','CiaoMondo'.proper_uncapitalize
	assert_equal 'ciaoMondo','ciaoMondo'.proper_uncapitalize
end

end