require 'codemodels/monkey_patching'

module CodeModels

class Parser

	def parse_file(path)
		parse_code(IO.read(path))
	end

end

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

# A Parser built wrapping a base parser written in Java
class ParserJavaWrapper < Parser

	attr_accessor :verbose

	def initialize
		@verbose = false
	end

protected 

	JavaCollection = ::Java::JavaClass.for_name("java.util.Collection")

	def log(msg)
		puts msg if verbose
	end
	
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
		return unless value==nil # we do not need to assign a nil...
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
		value = get_feature_value(node,att)
		model.send(:"#{att.name}=",value) if value!=nil
	rescue Object => e
		puts "Problem while populating attribute #{att.name} of #{model} from #{node}. Value: #{value}"
		raise e
	end

	def populate_ref(node,ref,model)
		log("populate ref #{ref.name}, node: #{node.class}, model: #{model.class}")
		value = get_feature_value(node,ref)
		log("\tvalue=#{value.class}")
		if value!=nil
			if value==node
				puts "avoiding loop... #{ref.name}, class #{node.class}" 
				return
			end
			if JavaCollection.assignable_from?(value.java_class)
				log("\tvalue is a collection")
				capitalized_name = ref.name.proper_capitalize				
				value.each do |el|
					unless el.respond_to?(:parent)
						class << el
							attr_accessor :parent						
						end
					end
					el.parent = node
					model.send(:"add#{capitalized_name}",node_to_model(el))
				end
			else
				log("\tvalue is not a collection")
				unless value.respond_to?(:parent)
					value.class.__persistent__ = true
					class << value
						attr_accessor :parent
					end
				end
				value.parent = node
				model.send(:"#{ref.name}=",node_to_model(value))
			end
		end
	end

	def node_to_model(node)
		log("node_to_model #{node.class}")
		metaclass = get_corresponding_metaclass(node)
		instance = metaclass.new
		metaclass.ecore.eAllAttributes.each do |attr|
			populate_attr(node,attr,instance)
		end
		metaclass.ecore.eAllReferences.each do |ref|
			populate_ref(node,ref,instance)
		end
		instance
	end

	def transform_enum_values(value)
		if value.respond_to?(:java_class) && value.java_class.enum?
			value.name
		else
			value
		end
	end

	def get_feature_value_through_getter(node,feat_name)
		capitalized_name = feat_name.proper_capitalize
		methods = [:"get#{capitalized_name}",:"is#{capitalized_name}"]

		methods.each do |m|
			if node.respond_to?(m)
				begin
					return transform_enum_values(node.send(m))
				rescue Object => e
					raise "Problem invoking #{m} on #{node.class}: #{e}"
				end
			end
		end
		raise "how should I get this... #{feat_name} on #{node.class}. It does not respond to #{methods}"
	end

	def get_feature_value(node,feat)
		adapter = adapter(node.class,feat)		
		if adapter
			adapter[:adapter].call(node)
		else
			get_feature_value_through_getter(node,feat.name)
		end
	end

end

end