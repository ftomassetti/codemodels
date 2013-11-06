# Extensions to RGen objects

require 'rgen/metamodel_builder'
require 'rgen/ext'

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

		def eql?(other)
			return false unless RGen::Ext::Comparison::DeepComparator.eql?(self,other)
			if self.respond_to?(:source) || other.respond_to?(:source)
				return false if (self.source==nil) != (other.source==nil)
				return true if self.source==nil
				return false if (self.source.position==nil) != (other.source.position==nil)				
				return true if self.source.position==nil
				return self.source.position(:absolute)==other.source.position(:absolute)
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
