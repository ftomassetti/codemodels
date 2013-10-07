require 'test_helper'

class TestForeignNavigation < Test::Unit::TestCase

include CodeModels

class B < CodeModelsAstNode
	has_attr 'id',String
	contains_many_uni 'bs', B
end

class C < CodeModelsAstNode
	has_attr 'id',String
	contains_many_uni 'bs', B
end

class A < CodeModelsAstNode
	has_attr 'id',String
	contains_many_uni 'bs', B
end

def setup
	@c1 = C.build 'c1'
	@c2 = C.build 'c2'
	@b1 = B.build 'b1'
	@b2 = B.build 'b2'
	@b3 = B.build 'b3'
	@b4 = B.build 'b4'
	@b5 = B.build 'b5'
	@a1 = A.build 'a1'

	@c1.addBs @b1
	@b1.addBs @b2
	@b1.addBs @b3
	@b4.addBs @b5
	@a1.addBs @b4
	@a1.addForeign_asts @c1
	@a1.addForeign_asts @c2
end

def test_all_children_also_foreign
	assert_equal [@b4,@c1,@c2],	@a1.all_children_also_foreign
	assert_equal [@b2,@b3],		@b1.all_children_also_foreign
	assert_equal [],			@b2.all_children_also_foreign
	assert_equal [],			@b3.all_children_also_foreign
	assert_equal [@b5],			@b4.all_children_also_foreign
	assert_equal [],			@b5.all_children_also_foreign
	assert_equal [@b1],			@c1.all_children_also_foreign
	assert_equal [],			@c2.all_children_also_foreign
end

def test_all_children_deep_also_foreign
	assert_equal [@b4,@b5,@c1,@b1,@b2,@b3,@c2],	@a1.all_children_deep_also_foreign
	assert_equal [@b2,@b3],						@b1.all_children_deep_also_foreign
	assert_equal [],							@b2.all_children_deep_also_foreign
	assert_equal [],							@b3.all_children_deep_also_foreign
	assert_equal [@b5],							@b4.all_children_deep_also_foreign
	assert_equal [],							@b5.all_children_deep_also_foreign
	assert_equal [@b1,@b2,@b3],					@c1.all_children_deep_also_foreign
	assert_equal [],							@c2.all_children_deep_also_foreign
end

def test_traverse_also_foreign
	ids = []
	@a1.traverse_also_foreign do |n|
		ids << n.id
	end
	assert_equal ['a1','b4','b5','c1','b1','b2','b3','c2'],ids
end

def test_container_also_foreign
	assert_equal nil,@a1.container_also_foreign
	assert_equal @c1,@b1.container_also_foreign
	assert_equal @b1,@b2.container_also_foreign
	assert_equal @b1,@b3.container_also_foreign
	assert_equal @a1,@b4.container_also_foreign
	assert_equal @b4,@b5.container_also_foreign
	assert_equal @a1,@c1.container_also_foreign
	assert_equal @a1,@c2.container_also_foreign
end

end
