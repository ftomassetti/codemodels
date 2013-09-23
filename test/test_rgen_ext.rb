require 'test_helper'

class TestRgenExt < Test::Unit::TestCase

class C < RGen::MetamodelBuilder::MMBase
	has_attr 'id',Integer
end

class D < RGen::MetamodelBuilder::MMBase
	has_attr 'id',Integer
	contains_one_uni  'c', C
end

class B < RGen::MetamodelBuilder::MMBase
	has_attr 'id',Integer
	contains_many_uni 'ds', D
end

class A < RGen::MetamodelBuilder::MMBase
	has_attr 'id',Integer
	contains_many_uni 'bs', B
	contains_one_uni  'c', C
end

def setup
	@d_1  = D.build(1)
	@d_2  = D.build(2)
	@d_3  = D.build(3)
	@c_4  = C.build(4)
	@c_5  = C.build(5)
	@c_6  = C.build(6)
	@b_7  = B.build(7)
	@b_8  = B.build(8)
	@b_9  = B.build(9)
	@a_10 = A.build(10)

	@d_1.c = @c_5

	@b_8.addDs @d_2
	@b_8.addDs @d_3
	@b_9.addDs @d_1	

	@a_10.addBs @b_9
	@a_10.addBs @b_8
	@a_10.c = @c_6
end

def assert_ids(expected,actual)
	assert_equal expected.count,actual.count
	expected.each do |e|
		assert actual.find {|a| a.id==e}, "Element with id #{e} not found"
	end
end

def test_children
	assert_ids [5], @d_1.children
	assert_ids [], @d_2.children
	assert_ids [], @d_3.children
	assert_ids [], @c_4.children
	assert_ids [], @c_5.children
	assert_ids [], @c_6.children
	assert_ids [], @b_7.children
	assert_ids [2,3], @b_8.children
	assert_ids [1], @b_9.children
	assert_ids [6,8,9], @a_10.children
end

def test_children_deep
	assert_ids [5], @d_1.children_deep
	assert_ids [], @d_2.children_deep
	assert_ids [], @d_3.children_deep
	assert_ids [], @c_4.children_deep
	assert_ids [], @c_5.children_deep
	assert_ids [], @c_6.children_deep
	assert_ids [], @b_7.children_deep
	assert_ids [2,3], @b_8.children_deep
	assert_ids [1,5], @b_9.children_deep
	assert_ids [6,8,9,2,3,1,5], @a_10.children_deep
end

end
