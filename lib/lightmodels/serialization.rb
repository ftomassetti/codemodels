# This code permit to transform EObjects in Hash objects
# containing lists and single values

require 'json'

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
	e_class = e_object.eClass
	e_package = e_class.ePackage
	"#{e_package.nsURI}##{e_class.name}"
end

def self.jsonize_attr_value(map,e_object,e_attr)
	value = e_object.eGet e_attr
	if e_attr.upperBound==1
		map["attr_#{e_attr.name}"] = value
	else
		l = []
		(0..(value.size-1)).each do |i|
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
	value = e_object.eGet e_ref

	propname = "relcont_#{e_ref.name}" if e_ref.containment
	propname = "relnoncont_#{e_ref.name}" if not e_ref.containment

	if e_ref.upperBound==1		
		map[propname] = jsonize_ref_single_el(value,e_ref.containment,adapters)
	else
		l = []
		(0..(value.size-1)).each do |i|
			l << jsonize_ref_single_el(value.get(i),e_ref.containment,adapters)
		end
		map[propname] = l
	end
end

def self.jsonize_obj(e_object, adapters={})
	if not e_object
		nil
	else 
		map = { 'type' => qname(e_object), 'id' => serialization_id(e_object) }
		e_class = e_object.eClass
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

def self.load_file(path,max_nesting=100)
	parse(File.read(path),{max_nesting: max_nesting})
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

end # module

end # module