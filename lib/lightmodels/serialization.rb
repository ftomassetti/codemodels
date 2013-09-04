# This code permit to transform EObjects in Hash objects
# containing lists and single values

require 'json'
require 'fileutils'

module LightModels

module Serialization

@serialization_ids = {} unless @serialization_ids
@next_serialization_id = 1 unless @next_serialization_id

class << self
	attr_reader :serialization_ids
	attr_accessor :next_serialization_id
end

def self.serialization_id(obj)
	unless LightModels::Serialization.serialization_ids[obj]		
		LightModels::Serialization.serialization_ids[obj] = LightModels::Serialization.next_serialization_id
		LightModels::Serialization.next_serialization_id += 1
	end
	LightModels::Serialization.serialization_ids[obj]
end

def self.qname(e_object)
	if e_object.respond_to? :eClass 
		e_class = e_object.eClass
		e_package = e_class.ePackage
		"#{e_package.nsURI}##{e_class.name}"
	else
		e_object.class.to_s
	end
end

def self.jsonize_attr_value(map,e_object,e_attr)
	if e_object.respond_to? :eGet
		value = e_object.eGet e_attr
	else
		value = e_object.send e_attr.name.to_sym
	end
	if e_attr.upperBound==1
		map["attr_#{e_attr.name}"] = value
	else
		l = []
		if value.respond_to? :size
			dim = value.size-1
		else
			dim = value.count-1
		end
		(0..(dim)).each do |i|
			l << value.get(i)
		end
		map["attr_#{e_attr.name}"] = l
	end
end

def self.jsonize_ref_single_el(single_value,containment,adapters)
	if containment
		jsonize_obj(single_value,adapters)
	else
		serialization_id(single_value)
	end
end

def self.jsonize_ref_value(map,e_object,e_ref,adapters)
	if e_object.respond_to? :eGet
		value = e_object.eGet e_ref
	else
		value = e_object.send e_ref.name.to_sym
	end

	propname = "relcont_#{e_ref.name}" if e_ref.containment
	propname = "relnoncont_#{e_ref.name}" if not e_ref.containment

	if e_ref.upperBound==1		
		map[propname] = jsonize_ref_single_el(value,e_ref.containment,adapters)
	else
		l = []
		(0..(value.size-1)).each do |i|
			if value.is_a? Array
				l << jsonize_ref_single_el(value.at(i),e_ref.containment,adapters)
			else
				l << jsonize_ref_single_el(value.get(i),e_ref.containment,adapters)
			end
		end
		map[propname] = l
	end
end

def self.jsonize_obj(e_object, adapters={})
	if not e_object
		nil
	else 
		map = { 'type' => qname(e_object), 'id' => serialization_id(e_object) }
		if e_object.respond_to? :eClass
			e_class = e_object.eClass			
		else
			e_class = e_object.class.ecore
		end
		e_class.eAllAttributes.each do |a|		
			jsonize_attr_value(map,e_object,a)
		end
		e_class.eAllReferences.each do |r|
			#puts "ref #{r.name} #{r.containment}"
			jsonize_ref_value(map,e_object,r,adapters)
		end
		if adapters.has_key? qname(e_object)
			adapters[qname(e_object)].adapt(e_object,map)
		end
		map
	end
end

def self.load_file(path,max_nesting=500)
	JSON.parse(File.read(path),{max_nesting: max_nesting})
end

def self.load_models_from_dir(dir,verbose=false,max=-1)
	per_type_values_map = Hash.new do |pt_hash,pt_key|	
		pt_hash[pt_key] = Hash.new do |pa_hash,pa_key|
			pa_hash[pa_key] = CountingMap.new
		end
	end

	n = 0
	files = Dir[dir+'/**/*.json']
	files = files[0..(max-1)] if max!=-1
	files.each do |f|
		n+=1
		puts "...#{n}) #{f}" if verbose
		model = ::JSON.load_file(f,max_nesting=500)
		EMF.traverse(model) do |n|
			if n
				puts "\tnode: #{n['type']}" if verbose
				EMF.attrs(n).each do |a|
					puts "\t\tattr: #{a}" if verbose
					per_type_values_map[n['type']][a].inc(n[a])
				end
			end
		end
	end
	per_type_values_map
end

def self.eobject_to_model(root,adapters={})
	@serialization_ids = {}
	@next_serialization_id = 1

	model = {}
	external_elements = if root.eResource
		root.eResource.contents.select {|e| e!=root}
	else
		[]
	end

	model['root'] = jsonize_obj(root,adapters)
	model['external_elements'] = []
	external_elements.each do |ee|
		model['external_elements'] << jsonize_obj(ee)
	end
	model
end

def self.rgenobject_to_model(root,adapters={})
	@serialization_ids = {}
	@next_serialization_id = 1

	model = {}
	external_elements = []

	model['root'] = jsonize_obj(root,adapters)
	model['external_elements'] = []
	external_elements.each do |ee|
		model['external_elements'] << jsonize_obj(ee)
	end
	model
end

def self.save_as_model(root,model_path)
	model = to_model(root)
	save_model(model,model_path)
end

def self.save_model(model,model_path, max_nesting=500)
	dir = File.dirname(model_path)
	FileUtils.mkdir_p(dir) 

	File.open(model_path, 'w') do |file| 		
		file.write(JSON.pretty_generate(model, :max_nesting => max_nesting))
	end
end

end # module

end # module