# encoding: utf-8

require 'json'
require 'fileutils'
require 'rgen/metamodel_builder'

module CodeModels

# Everything related to serialization to Hash, lists and basic values
# is contained in this module
module Serialization

# Intended to be included
module SerializationFunctionalities

	# Deprecated, use to_hash instead
	def to_json(params={})
		to_hash(params)
	end

	def to_hash(params={})
		serialization_memory = params.fetch(:memory,SerializationMemory.new)
		adapters			 = params.fetch(:adapters,{})
		with_source_info	 = params.fetch(:source_info,true)

		e_object = self
		map = { 'type' => type, 'id' => serialization_memory.id(e_object) }
		if with_source_info
			if self.respond_to?(:source) && self.source								
				map['source'] = source_info_to_hash(self.source)
			end
		end
		e_class = e_object.class.ecore
		e_class.eAllAttributes.sort_by { |a| a.name }.each do |a|		
			insert_attr_value_in_hash(map,a)
		end
		e_class.eAllReferences.sort_by { |r| r.name }.each do |r|
			id = insert_ref_value_in_hash(map,r,adapters,serialization_memory)
		end
		if adapters.has_key? type
			adapters[type].adapt(self,map)
		end
		map
	end

	private

	def source_info_to_hash(source_info)
		source_map = {}
		if self.source.begin_point
			source_map['begin_point'] = {'line'=> self.source.begin_point.line, 'column'=>self.source.begin_point.column}
		end				
		if self.source.end_point
			source_map['end_point'] = {'line'=> self.source.end_point.line, 'column'=>self.source.end_point.column}
		end			
		source_map	
	end

	def type
		self.class.to_s
	end

	def insert_attr_value_in_hash(map,e_attr)
		value = self.send(e_attr.name.to_sym)
		unless e_attr.many
			map["attr_#{e_attr.name}"] = value
		else
			l = []
			value.each do |e|
				l << e
			end
			map["attr_#{e_attr.name}"] = l
		end
	end

	def insert_ref_value_in_hash(map,e_ref,adapters,serialization_memory)
		value = self.send e_ref.name.to_sym

		propname = "relcont_#{e_ref.name}" if e_ref.containment
		propname = "relnoncont_#{e_ref.name}" if not e_ref.containment

		unless e_ref.many		
			map[propname] = insert_ref_single_value_in_hash(value,e_ref.containment,adapters,serialization_memory)
		else
			l = []
			(0...(value.size)).each do |i|				
				l << insert_ref_single_value_in_hash(value.at(i),e_ref.containment,adapters,serialization_memory)
			end
			map[propname] = l
		end
	end

	def insert_ref_single_value_in_hash(single_value,containment,adapters,serialization_memory)
		if containment
			single_value.to_json(memory:serialization_memory,adapters:adapters)
		else
			serialization_memory.id(single_value)
		end
	end

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

end

def self.load_file(path,max_nesting=500)
	JSON.parse(File.read(path),{max_nesting: max_nesting})
end

def self.save_model(model,model_path,max_nesting=500)
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
	model['root'] = root.to_json(memory:sm,adapters:adapters)
	model['external_elements'] = []
	external_elements.each do |ee|
		model['external_elements'] << ee.to_json(memory:sm,adapters:adapters)
	end
	model
end

def self.save_as_model(root,model_path)
	model = to_model(root)
	save_model(model,model_path)
end

end # module

end # module