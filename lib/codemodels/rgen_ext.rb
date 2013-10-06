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
					raise "UnexistingFeature #{k}" unless (attribute or reference)
					setter = (k.to_s+'=').to_sym
					instance.send setter, v
				end
			else
				raise "SingleAttributeRequired" if self.ecore.eAllAttributes.count!=1
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
				self_value  = self.get(attrib)
				other_value = other.get(attrib)
				return false unless self_value == other_value
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
								unless self_value[i].shallow_eql?(other_value[i])
									return false 
								end
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

		def features_by_name(name)
			features = []
			ecore = self.class.ecore
			ecore.eAllAttributes.select {|a| a.name==name}.each do |a|
				features << a
			end			
			ecore.eAllReferences.select {|r| r.name==name}.each do |r|
				features << r
			end
			features
		end

	end

	module FixingCollidingFeatureAddOn
		def has_attr(role, target_class=nil, raw_props={}, &block)
			raise "Role already used #{role}" if self.ecore.eAllAttributes.find {|a| a.name==role.to_s}
			raise "Role already used #{role}" if self.ecore.eAllReferences.find {|r| r.name==role.to_s}
			super(role,target_class,raw_props,block)
		end
		def has_many_attr(role, target_class=nil, raw_props={}, &block)
			raise "Role already used #{role}" if self.ecore.eAllAttributes.find {|a| a.name==role.to_s}
			raise "Role already used #{role}" if self.ecore.eAllReferences.find {|r| r.name==role.to_s}
			super(role,target_class,raw_props,block)
		end
		def contains_many_uni(role, target_class=nil, raw_props={}, &block)
			raise "Role already used #{role}" if self.ecore.eAllAttributes.find {|a| a.name==role.to_s}
			raise "Role already used #{role}" if self.ecore.eAllReferences.find {|r| r.name==role.to_s}
			super(role,target_class,raw_props,block)
		end
		def contains_one_uni(role, target_class=nil, raw_props={}, &block) 
			raise "Role already used #{role}" if self.ecore.eAllAttributes.find {|a| a.name==role.to_s}
			raise "Role already used #{role}" if self.ecore.eAllReferences.find {|r| r.name==role.to_s}
			super(role,target_class,raw_props,block)
		end
	end

	class << self
		include ClassAddOn
	end

	include FixingCollidingFeatureAddOn
	include SingletonAddOn
end
