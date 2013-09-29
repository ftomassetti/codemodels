require 'test_helper'

class TestForeignAst < Test::Unit::TestCase

include CodeModels

class MyLanguageAstNodeA < CodeModelsAstNode
	has_attr 'id', Integer
end

class MyLanguageAstNodeB < CodeModelsAstNode
	has_attr 'id', Integer
end

def setup
end

def test_without_foreign_ast
	assert_equal 0, MyLanguageAstNodeA.ecore.eAllReferences.count, "No Refs expected but they are: #{MyLanguageAstNodeA.ecore.eAllReferences.name}"
end

def test_with_foreign_ast
	CodeModels.enable_foreign_asts(MyLanguageAstNodeB)
	assert_equal 1, MyLanguageAstNodeB.ecore.eAllReferences.count
	assert_equal 'foreign_asts',MyLanguageAstNodeB.ecore.eAllReferences[0].name
end

end