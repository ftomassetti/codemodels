require 'emf_jruby'
require 'lightmodels'
require 'test/unit'
require 'rgen/metamodel_builder'

include LightModels

class TestSerializationEmf < Test::Unit::TestCase

	Pack = EMF.create_epackage('my_pack','my_pack_uri')

	Person = EMF.create_eclass Pack
	Person.eStructuralFeatures.add EMF.create_eattribute_str('name')

	def test_to_model_with_single_obj
		p = EMF.create_eobject(Person)
		m = Serialization.eobject_to_model(p)

		assert_equal 1,m['root']['id']
		assert_equal 0,m['external_elements'].count
	end

end

class TestSerializationRgen < Test::Unit::TestCase

	class Person < RGen::MetamodelBuilder::MMBase
		has_attr 'name', String
	end

	def test_to_model_with_single_obj
		p = Person.build 'pippo'
		m = Serialization.rgenobject_to_model(p)

		assert_equal 1,m['root']['id']
		assert_equal 'pippo',m['root']['attr_name']
		assert_equal 0,m['external_elements'].count
	end

end