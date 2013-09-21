require 'test_helper'

class TestQuerySerialized < Test::Unit::TestCase

def test_rel_conts_on_complex_node
	set_completed = JSON.parse(IO.read(File.dirname(__FILE__)+'/data/node_setCompleted.json'))

	assert_equal [
			'relcont_layoutInformations',
			'relcont_typeReference',
			'relcont_arrayDimensionsBefore',
			'relcont_arrayDimensionsAfter',
			'relcont_typeParameters',
			'relcont_parameters',
			'relcont_exceptions',
			'relcont_annotationsAndModifiers',
			'relcont_statements'], 
		LightModels::QuerySerialized.rel_conts(set_completed)
end

def test_rel_nonconts_on_complex_node
	set_completed = JSON.parse(IO.read(File.dirname(__FILE__)+'/data/node_setCompleted.json'))

	assert_equal [
			'relnoncont_getterFor',
			'relnoncont_setterFor'], 
		LightModels::QuerySerialized.rel_non_conts(set_completed)
end

def test_attrs_on_complex_node
	set_completed = JSON.parse(IO.read(File.dirname(__FILE__)+'/data/node_setCompleted.json'))

	assert_equal [
			'attr_name',
			'attr_getter',
			'attr_setter'], 
		LightModels::QuerySerialized.attrs(set_completed)
end

end