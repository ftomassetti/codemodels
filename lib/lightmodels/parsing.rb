module LightModels

class ParsingError < Exception
 	attr_reader :node
 	attr_reader :line

 	def initialize(node,msg,line=nil)
 		@node = node
 		@msg = msg
 		@line = lin
 	end

 	def to_s
 		"#{@msg}, start line: #{@line}"
 	end

end

class UnknownNodeType < ParsingError

 	def initialize(node,line=nil,node_type=nil,where=nil)
 		super(node,"UnknownNodeType: type=#{node_type} , where: #{where}")
 	end

end

module ParserWrapper
	
def adapter(model_class,ref)
	if adapter_specific_class(model_class,ref)
		adapter_specific_class(model_class,ref)
	else
		if model_class.superclass!=Object
			adapter(model_class.superclass,ref) 
		else
			nil
		end
	end
end

def reference_to_method(model_class,ref)
	s = ref.name
	#s = 'value' if s=='body'
	adapted = adapter(model_class,ref)
	s = adapted if adapted		
	s.to_sym
end

def attribute_to_method(model_class,att)
	s = att.name
	adapted = adapter(model_class,att)
	s = adapted if adapted		
	s.to_sym
end

def assign_ref_to_model(model,ref,value)
	return unless value # we do not need to assign a nil...
	if ref.many
		adder_method = :"add#{ref.name.capitalize}"
		value.each {|el| model.send(adder_method,node_to_model(el))}
	else
		setter_method = :"#{ref.name}="
		raise "Trying to assign an array to a single property. Class #{model.class}, property #{ref.name}" if value.is_a?(::Array)
		model.send(setter_method,node_to_model(value))
	end
rescue Object => e
	puts "Problem while assigning ref #{ref.name} (many? #{ref.many}) to #{model.class}. Value: #{value.class}"
	puts "\t<<#{e}>>"
	raise e
end

def assign_att_to_model(model,att,value)
	if att.many
		adder_method = :"add#{att.name.capitalize}"
		value.each {|el| model.send(adder_method,el)}
	else
		setter_method = :"#{att.name}="
		raise "Trying to assign an array to a single property. Class #{model.class}, property #{att.name}" if value.is_a?(::Array)
		model.send(setter_method,value)
	end
end

def populate_attr(node,att,model)	
	value = get_feature_value(node,att.name)
	#puts "Value got for #{node.class} #{att} : #{value.class}"
	# nil are ignored
	model.send(:"#{att.name}=",value) if value
end

def populate_ref(node,ref,model)
	value = get_feature_value(node,ref.name)
	if value
		if value==node
			puts "avoiding loop... #{ref.name}, class #{node.class}" 
			return
		end
		if value.is_a?(Java::JavaUtil::Collection)
			capitalized_name = ref.name.proper_capitalize	
			value.each do |el|
				model.send(:"add#{capitalized_name}",node_to_model(el))
			end
		else
			model.send(:"#{ref.name}=",node_to_model(value))
		end
	end
end

def node_to_model(node)
	metaclass = get_corresponding_metaclass(node.class)
	instance = metaclass.new
	metaclass.ecore.eAllAttributes.each do |attr|
		populate_attr(node,attr,instance)
	end
	metaclass.ecore.eAllReferences.each do |ref|
		populate_ref(node,ref,instance)
	end
	instance
end

end

end