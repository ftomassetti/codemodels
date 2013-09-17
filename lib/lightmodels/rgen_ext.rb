# Extensions to RGen objects

require 'rgen/metamodel_builder'

class RGen::MetamodelBuilder::MMBase

	module ClassAddOn

		def build(values={})
			instance = self.new
			if values.is_a? Hash
				values.each do |k,v|
					attribute = self.ecore.eAllAttributes.find {|x| x.name==k.to_s}
					reference = self.ecore.eAllReferences.find {|x| x.name==k.to_s}
					raise EMF::UnexistingFeature.new(k.to_s) unless (attribute or reference)
					setter = (k.to_s+'=').to_sym
					instance.send setter, v
				end
			else
				has_dynamic = false
				self.ecore.eAllAttributes.each {|a| has_dynamic|=a.name=='dynamic'}
				d = 0
				d = 1 if has_dynamic

				raise EMF::SingleAttributeRequired.new(self.ecore.name,self.ecore.eAllAttributes) if self.ecore.eAllAttributes.count!=1+d
				attribute = self.ecore.eAllAttributes[0]
				set_attr(instance,attribute,values)
			end
			instance
		end

		private

		def set_attr(instance,attribute,value)
			setter = (attribute.name+'=').to_sym
			instance.send setter, value
		end
	end

	module SingletonAddOn

		# It does not check references, it is needed to avoid infinite recursion
		def shallow_eql?(other)
			return false if other==nil
			return false unless self.class==other.class
			self.class.ecore.eAllAttributes.each do |attrib|
				raise "Attrib <nil> for class #{self.class.ecore.name}" unless attrib
				if attrib.name != 'dynamic' # I have to understand this...
					self_value  = self.get(attrib)
					other_value = other.get(attrib)
					#puts "returning false on #{attrib.name}" unless self_value.eql?(other_value)
					return false unless self_value == other_value
				end
			end
			true
		end

		def eql?(other)
			# it should ignore relations which has as opposite a containement
			return false unless self.shallow_eql?(other)
			self.class.ecore.eAllReferences.each do |ref|
				self_value = self.get(ref)
				other_value = other.get(ref)
				to_ignore = ref.getEOpposite and ref.getEOpposite.containment
				unless to_ignore
					if ref.containment
						return false unless self_value == other_value
					else
						if (self_value.is_a? Array) or (other_value.is_a? Array)
							return false unless self_value.count==other_value.count
							for i in 0..(self_value.count-1)
								return false unless self_value[i].shallow_eql?(other_value[i])
							end
						else  
							if self_value==nil
								return false unless other_value==nil
							else
								return false unless self_value.shallow_eql?(other_value)
							end
						end
					end
				end						
			end
			true
		end

		def ==(other)
			eql? other
		end
	
		def get(attr_or_ref)
			getter = (attr_or_ref.name).to_sym
			send getter
		end

		def children
			arr = []
			ecore = self.class.ecore
			ecore.eAllReferences.select {|r| r.containment}.each do |ref|
				res = self.send(ref.name.to_sym)
				if res.is_a? Array
					arr.concat(res)
				elsif res
					arr << res
				end
			end
			arr
		end

		def children_deep
			arr = []
			children.each do |c|
				arr << c
				arr.concat(c.children_deep)
			end			
			arr
		end

		def children_of_type(type)
			children.select {|c| c and c.is_a?(type)}
		end

		def children_deep_of_type(type)
			children_deep.select {|c| c and c.is_a?(type)}
		end

		def only_child_of_type(type)
			selected = children_of_type(type)
			raise "Exactly one child of type #{type} expected, #{selected.count} found on #{self}" unless selected.count==1
			selected[0]
		end

		def only_child_deep_of_type(type)
			selected = children_deep_of_type(type)
			raise "Exactly one child of type #{type} expected, #{selected.count} found on #{self}" unless selected.count==1
			selected[0]
		end

	end

	class << self
		include ClassAddOn
	end

	include SingletonAddOn
end
