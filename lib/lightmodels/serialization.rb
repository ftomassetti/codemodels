# This code permit to transform RGen-Objects in Hash objects
# containing lists and single values

require 'json'
require 'fileutils'

module LightModels
module Serialization

module SerializationFunctionalities

	# It could be a simple hash with a block passed to the
	# constructor...
	class SerializationMemory

		def initialize
			@next_id = 1
			@id_map = {}
		end

		def id(rgen_object)
			unless @id_map[rgen_object]
				@id_map[rgen_object] = @next_id
				@next_id += 1
			end
			@id_map[rgen_object]
		end

	end

	def to_json(serialization_memory=SerializationMemory.new,adapters={})
		e_object = self
		map = { 'type' => qname, 'id' => serialization_memory.id(e_object) }
		e_class = e_object.class.ecore
		e_class.eAllAttributes.each do |a|		
			jsonize_attr_value(map,a)
		end
		e_class.eAllReferences.each do |r|
			id = jsonize_ref_value(map,r,adapters,serialization_memory)
		end
		if adapters.has_key? qname
			adapters[qname].adapt(self,map)
		end
		map
	end

	private

	def qname
		self.class.to_s
	end

	def jsonize_attr_value(map,e_attr)
		value = self.send(e_attr.name.to_sym)
		if e_attr.upperBound==1
			map["attr_#{e_attr.name}"] = value
		else
			l = []
			value.each do |e|
				l << e
			end
			map["attr_#{e_attr.name}"] = l
		end
	end

	def jsonize_ref_value(map,e_ref,adapters,serialization_memory)
		value = self.send e_ref.name.to_sym

		propname = "relcont_#{e_ref.name}" if e_ref.containment
		propname = "relnoncont_#{e_ref.name}" if not e_ref.containment

		if e_ref.upperBound==1		
			map[propname] = jsonize_ref_single_el(value,e_ref.containment,adapters,serialization_memory)
		else
			l = []
			(0...(value.size)).each do |i|				
				l << jsonize_ref_single_el(value.at(i),e_ref.containment,adapters,serialization_memory)
			end
			map[propname] = l
		end
	end

	def jsonize_ref_single_el(single_value,containment,adapters,serialization_memory)
		if containment
			single_value.to_json(serialization_memory,adapters)
		else
			serialization_memory.id(single_value)
		end
	end

end

class ::RGen::MetamodelBuilder::MMBase
	include SerializationFunctionalities
end

def self.load_file(path,max_nesting=500)
	JSON.parse(File.read(path),{max_nesting: max_nesting})
end

def self.save_model(model,model_path, max_nesting=500)
	dir = File.dirname(model_path)
	FileUtils.mkdir_p(dir) 

	File.open(model_path, 'w') do |file| 		
		file.write(JSON.pretty_generate(model, :max_nesting => max_nesting))
	end
end

def self.rgenobject_to_model(root,adapters={})
	model = {}
	external_elements = []

	sm = SerializationFunctionalities::SerializationMemory.new
	model['root'] = root.to_json(sm,adapters)
	model['external_elements'] = []
	external_elements.each do |ee|
		model['external_elements'] << ee.to_json(sm,adapters)
	end
	model
end

def self.save_as_model(root,model_path)
	model = to_model(root)
	save_model(model,model_path)
end

end # module
end # module