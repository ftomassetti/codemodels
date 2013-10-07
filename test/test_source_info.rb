require 'test_helper'

class TestSourceInfo < Test::Unit::TestCase

include CodeModels

def setup

end

def test_source_point_from_code_index
	code = "first line\nsecond line\nthird line\n"
	
	# first line
	assert_equal SourcePoint.new(1,1),SourcePoint.from_code_index(code,0)
	assert_equal SourcePoint.new(1,2),SourcePoint.from_code_index(code,1)
	assert_equal SourcePoint.new(1,3),SourcePoint.from_code_index(code,2)
	assert_equal SourcePoint.new(1,9),SourcePoint.from_code_index(code,8)
	assert_equal SourcePoint.new(1,10),SourcePoint.from_code_index(code,9)

	# new line
	assert_equal SourcePoint.new(2,0),SourcePoint.from_code_index(code,10)

	# second line
	assert_equal SourcePoint.new(2,1),SourcePoint.from_code_index(code,11)
	assert_equal SourcePoint.new(2,2),SourcePoint.from_code_index(code,12)
	assert_equal SourcePoint.new(2,10),SourcePoint.from_code_index(code,20)
	assert_equal SourcePoint.new(2,11),SourcePoint.from_code_index(code,21)

	# new line
	assert_equal SourcePoint.new(3,0),SourcePoint.from_code_index(code,22)	

	# third line
	assert_equal SourcePoint.new(3,1),SourcePoint.from_code_index(code,23)
	assert_equal SourcePoint.new(3,10),SourcePoint.from_code_index(code,32)

	# new line
	assert_equal SourcePoint.new(4,0),SourcePoint.from_code_index(code,33)
end



end