require 'test_helper'

class TestRgenExt < Test::Unit::TestCase

class C < CodeModels::CodeModelsAstNode
	has_attr 'id',Integer
end

class D < CodeModels::CodeModelsAstNode
	has_attr 'id',Integer
	contains_one_uni  'c', C
end

class B < CodeModels::CodeModelsAstNode
	has_attr 'id',Integer
	contains_many_uni 'ds', D
end

class A < CodeModels::CodeModelsAstNode
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
	assert_ids [5], @d_1.all_children
	assert_ids [], @d_2.all_children
	assert_ids [], @d_3.all_children
	assert_ids [], @c_4.all_children
	assert_ids [], @c_5.all_children
	assert_ids [], @c_6.all_children
	assert_ids [], @b_7.all_children
	assert_ids [2,3], @b_8.all_children
	assert_ids [1], @b_9.all_children
	assert_ids [6,8,9], @a_10.all_children
end

def test_children_deep
	assert_ids [5], @d_1.all_children_deep
	assert_ids [], @d_2.all_children_deep
	assert_ids [], @d_3.all_children_deep
	assert_ids [], @c_4.all_children_deep
	assert_ids [], @c_5.all_children_deep
	assert_ids [], @c_6.all_children_deep
	assert_ids [], @b_7.all_children_deep
	assert_ids [2,3], @b_8.all_children_deep
	assert_ids [1,5], @b_9.all_children_deep
	assert_ids [6,8,9,2,3,1,5], @a_10.all_children_deep
end

def test_traverse
	l = []
	@a_10.traverse {|n| l<<n if n }
	assert_ids [10,6,8,9,2,3,1,5], l
end

def test_equal_without_children
	a = D.build(1)
	b = D.build(1)
	c = D.build(2)
	d = C.build(2)
	assert_equal true,  a==b
	assert_equal false, a==c
	assert_equal false, d==c # different type
end

def test_equal_wit_children
	c1 = C.build(1)
	c2 = C.build(1)
	d1 = D.build(1)
	d2 = D.build(1)
	d1.c = c1
	d2.c = c2
	assert_equal true,  d1==d2
	c3 = C.build(2)
	d2.c = c3
	assert_equal false, d1==d2 # a child is different
end

def test_build_with_one_attribute
	c = C.build(1)
	assert_equal 1,c.id
end

class McWithTwoAttrs < RGen::MetamodelBuilder::MMBase
	has_attr 'i',Integer
	has_attr 's',String
end

def test_build_with_multiple_attributes
	c = McWithTwoAttrs.build i: 27, s: 'Federico'
	assert_equal 27,c.i
	assert_equal 'Federico',c.s
end

class McWithNonContRef < RGen::MetamodelBuilder::MMBase
	has_one 'mcwta',McWithTwoAttrs
end

def test_equal_with_non_cont_ref_single
	mcwta1 = McWithTwoAttrs.build i: 27, s: 'Federico'
	mcwta2 = McWithTwoAttrs.build i: 27, s: 'Federico'
	mcwta3 = McWithTwoAttrs.build i: 27, s: 'Federico Filippo'
	c1 = McWithNonContRef.new
	c1.mcwta = mcwta1
	c2 = McWithNonContRef.new
	c2.mcwta = mcwta1
	assert_equal true, c1==c2
	c2.mcwta = mcwta2
	assert_equal true, c1==c2
	c2.mcwta = mcwta3
	assert_equal false, c1==c2
end

def test_equal_with_nil_ref
	mcwta1 = McWithTwoAttrs.build i: 27, s: 'Federico'
	c1 = McWithNonContRef.new
	c2 = McWithNonContRef.new
	assert_equal true, c1==c2 # both nil
	c1.mcwta = mcwta1
	assert_equal false, c1==c2 # one nil, the other not
	assert_equal false, c2==c1 # inverting them do I get a npe?
end

class McWithNonContRefMany < RGen::MetamodelBuilder::MMBase
	has_many 'mcwtas',McWithTwoAttrs
end

def test_rgen_issue_10_is_in_place
	mcwta1 = McWithTwoAttrs.build i: 27, s: 'Federico'
	c1 = McWithNonContRefMany.new
	c1.addMcwtas(mcwta1)	
	c1.addMcwtas(mcwta1)
	assert_equal 1,c1.mcwtas.count
end

def test_equal_with_non_cont_ref_many
	mcwta1 = McWithTwoAttrs.build i: 27, s: 'Federico'
	mcwta2 = McWithTwoAttrs.build i: 27, s: 'Federico'
	mcwta3 = McWithTwoAttrs.build i: 27, s: 'Federico Filippo'
	mcwta4 = McWithTwoAttrs.build i: 29, s: 'Federico Filippo'
	c1 = McWithNonContRefMany.new
	c2 = McWithNonContRefMany.new
	assert_equal true, c1==c2
	c1.addMcwtas(mcwta2)	
	c2.addMcwtas(mcwta1)
	assert_equal true, c1==c2
	c1.addMcwtas(mcwta1)
	c2.addMcwtas(mcwta2)
	assert_equal true, c1==c2
	c1.addMcwtas(mcwta4)
	c2.addMcwtas(mcwta3)
	assert_equal false, c1==c2
end


end
