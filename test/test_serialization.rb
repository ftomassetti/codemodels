require 'test_helper'

class TestSerialization < Test::Unit::TestCase

	class Person < CodeModelsAstNode
		has_attr 'name', String
	end

	class Street < CodeModelsAstNode
		has_attr 'name', String
	end

	class Address < CodeModelsAstNode
		contains_one_uni 'street', Street
		has_attr 'number', Integer
	end	

	class StupidPhoneBook < CodeModelsAstNode
		has_many_attr 'numbers', String
	end

	def test_to_model_with_single_obj
		p = Person.build 'pippo'
		m = Serialization.rgenobject_to_model(p)
		
		assert_equal 1,m['root']['id']
		assert_equal 0,m['external_elements'].count
	end

	def test_to_model_with_attr
		p = Person.build 'pippo'
		m = Serialization.rgenobject_to_model(p)

		assert_equal 'pippo',m['root']['attr_name']
	end

	def test_to_model_with_rel_cont_single
		a = Address.build number: 11
		a.street = Street.build 'via Cassini'		 
		m = Serialization.rgenobject_to_model(a)
				
		street_serialized = m['root']['relcont_street']
		assert_not_nil street_serialized
		assert_equal 'via Cassini',street_serialized['attr_name']
	end

	class Street < CodeModelsAstNode
		has_attr 'name', String
	end

	class CityMap < CodeModelsAstNode
		contains_many_uni 'streets', Street
	end	

	def test_to_model_with_rel_cont_multi
		cm = CityMap.new
		cm.streets = cm.streets << Street.build('via Cassini')
		cm.streets = cm.streets << Street.build('piazza Emanuele Filiberto')
		m = Serialization.rgenobject_to_model(cm)
				
		streets_serialized = m['root']['relcont_streets']
		assert_not_nil streets_serialized
		assert_equal 2, streets_serialized.count
		assert_equal 'via Cassini',streets_serialized[0]['attr_name']
		assert_equal 'piazza Emanuele Filiberto',streets_serialized[1]['attr_name']
	end

	def test_to_json_multi_attr
		spb = StupidPhoneBook.new
		spb.addNumbers '+49 0176 12345678'
		spb.addNumbers '+39 389 4561234'

		assert_equal({
			"type"=>"TestSerialization::StupidPhoneBook", 
			"id"=>1, 
			"attr_numbers"=>[
				"+49 0176 12345678", 
				"+39 389 4561234"
			]},
			spb.to_json)
	end

end