# Extensions to RGen objects

require 'rgen/metamodel_builder'
require 'rgen/ext'

class RGen::MetamodelBuilder::MMBase

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

	include FixingCollidingFeatureAddOn
	include SingletonAddOn
end
