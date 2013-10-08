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

def test_source_point_absolute_index
	code = "first line\nsecond line\nthird line\n"
	p1 = SourcePoint.new(1,1)	
	p2 = SourcePoint.new(1,5)
	p3 = SourcePoint.new(1,10)
	p4 = SourcePoint.new(2,6)
	p5 = SourcePoint.new(2,2)
	p7 = SourcePoint.new(3,1)
	p8 = SourcePoint.new(3,10)

	assert_equal 0,p1.to_absolute_index(code)
	assert_equal 4,p2.to_absolute_index(code)
	assert_equal 9,p3.to_absolute_index(code)
	assert_equal 16,p4.to_absolute_index(code)
	assert_equal 12,p5.to_absolute_index(code)
	assert_equal 23,p7.to_absolute_index(code)
	assert_equal 32,p8.to_absolute_index(code)
end

def test_source_position_get_string
	code = "first line\nsecond line\nthird line\n"

	p1 = SourcePoint.new(1,1)
	p2 = SourcePoint.new(1,5)
	pos1 = SourcePosition.new(p1,p2)
	assert_equal "first",pos1.get_string(code)

	p3 = SourcePoint.new(1,10)
	pos2 = SourcePosition.new(p1,p3)
	assert_equal "first line",pos2.get_string(code)

	p4 = SourcePoint.new(2,6)
	pos3 = SourcePosition.new(p1,p4)
	assert_equal "first line\nsecond",pos3.get_string(code)

	p5 = SourcePoint.new(2,2)
	p6 = SourcePoint.new(2,6)
	pos4 = SourcePosition.new(p5,p6)
	assert_equal "econd",pos4.get_string(code)

	p7 = SourcePoint.new(3,1)
	p8 = SourcePoint.new(3,10)
	pos5 = SourcePosition.new(p7,p8)
	assert_equal "third line",pos5.get_string(code)
end

def test_source_point_comparison
	p1 = SourcePoint.new(1,1)
	p2 = SourcePoint.new(1,1)
	p3 = SourcePoint.new(1,3)
	p4 = SourcePoint.new(2,1)
	p5 = SourcePoint.new(2,6)

	assert_equal  0,p1<=>p1
	assert_equal  0,p1<=>p2
	assert_equal -1,p1<=>p3
	assert_equal -1,p1<=>p4
	assert_equal -1,p1<=>p5

	assert_equal  0,p2<=>p1
	assert_equal  0,p2<=>p2
	assert_equal -1,p2<=>p3
	assert_equal -1,p2<=>p4
	assert_equal -1,p2<=>p5	

	assert_equal  1,p3<=>p1
	assert_equal  1,p3<=>p2
	assert_equal  0,p3<=>p3
	assert_equal -1,p3<=>p4
	assert_equal -1,p3<=>p5	

	assert_equal  1,p4<=>p1
	assert_equal  1,p4<=>p2
	assert_equal  1,p4<=>p3
	assert_equal  0,p4<=>p4
	assert_equal -1,p4<=>p5	

	assert_equal  1,p5<=>p1
	assert_equal  1,p5<=>p2
	assert_equal  1,p5<=>p3
	assert_equal  1,p5<=>p4
	assert_equal  0,p5<=>p5	
end

def test_source_position_include
	p1 = SourcePoint.new(1,1)
	p2 = SourcePoint.new(1,1)
	p3 = SourcePoint.new(1,3)
	p4 = SourcePoint.new(2,1)
	p5 = SourcePoint.new(2,6)

	assert_equal true,SourcePosition.new(p1,p2).include?(SourcePosition.new(p2,p1))
	assert_equal true,SourcePosition.new(p1,p5).include?(SourcePosition.new(p3,p4))
	assert_equal true,SourcePosition.new(p3,p5).include?(SourcePosition.new(p4,SourcePoint.new(2,2)))
	assert_equal false,SourcePosition.new(p3,p4).include?(SourcePosition.new(p4,p5))
	assert_equal false,SourcePosition.new(p1,p4).include?(SourcePosition.new(p1,p5))
end

end