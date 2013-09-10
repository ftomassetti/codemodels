require 'lightmodels'
require 'test/unit'

class TestStats < Test::Unit::TestCase

EcoreLiterals = JavaUtilities.get_proxy_class('org.eclipse.emf.ecore.EcorePackage$Literals')

Pack = EMF.create_epackage('my_pack','my_pack_uri')

Person = EMF.create_eclass Pack
Person.eStructuralFeatures.add EMF.create_eattribute_str('name')

Address = EMF.create_eclass Pack
Address.eStructuralFeatures.add EMF.create_eattribute_str('street')
Address.eStructuralFeatures.add EMF.create_eattribute('number',EcoreLiterals::ELONG)

Person.eStructuralFeatures.add EMF.create_ereference(Address, 'home_address', [:containment])

def test_rel_conts_on_simple_node
	federico = EMF.create_eobject(Person)
	lm = Serialization.eobject_to_model(federico)['root']
	assert_equal 1,LightModels::Query.rel_conts(lm).count
	assert_equal 'relcont_home_address',LightModels::Query.rel_conts(lm)[0]
end	


def test_rel_conts_on_complex_node
	set_completed = JSON.parse(IO.read(File.dirname(__FILE__)+'/node_setCompleted.json'))

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
		LightModels::Query.rel_conts(set_completed)
end

def test_rel_nonconts_on_complex_node
	set_completed = JSON.parse(IO.read(File.dirname(__FILE__)+'/node_setCompleted.json'))

	assert_equal [
			'relnoncont_getterFor',
			'relnoncont_setterFor'], 
		LightModels::Query.rel_non_conts(set_completed)
end

def test_attrs_on_complex_node
	set_completed = JSON.parse(IO.read(File.dirname(__FILE__)+'/node_setCompleted.json'))

	assert_equal [
			'attr_name',
			'attr_getter',
			'attr_setter'], 
		LightModels::Query.attrs(set_completed)
end

end