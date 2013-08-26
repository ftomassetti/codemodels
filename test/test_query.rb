require 'lightmodels'
require 'test/unit'

include LightModels

class TestStats < Test::Unit::TestCase

	Pack = EMF.create_epackage('my_pack','my_pack_uri')

	Person = EMF.create_eclass Pack
	Person.eStructuralFeatures.add EMF.create_eattribute_str('name')

	def test_collect_values_empty
		p = EMF.create_eobject(Person)
		m = Serialization.to_model(p)

		assert_equal 0,Query.collect_values(m['root']).count
	end

	def test_collect_values_single_value
		p = EMF.create_eobject(Person)
		p.set_attr_value('name','Federico')
		m = Serialization.to_model(p)

		assert_equal 1,Query.collect_values(m['root']).count
		assert Query.collect_values(m['root']).include? 'Federico'
	end

end