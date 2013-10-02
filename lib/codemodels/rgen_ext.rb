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

		def all_children
			arr = []
			ecore = self.class.ecore
			# Awful hack to forbid the same reference is visited twice when
			# two references with the same name are found
			already_used_references = []
			ecore.eAllReferences.select {|r| r.containment}.each do |ref|
				#raise "Too many features with name #{ref.name}. Count: #{features_by_name(ref.name).count}" if features_by_name(ref.name).count!=1
				unless already_used_references.include?(ref.name)
					res = self.send(ref.name.to_sym)
					if ref.many
						d = arr.count
						res.each do |el|
							arr << el unless res==nil
						end
					elsif res!=nil
						d = arr.count
						arr << res
					end
					already_used_references << ref.name
				end
			end
			arr
		end

		def all_children_deep
			arr = []
			all_children.each do |c|
				arr << c
				c.all_children_deep.each do |cc|
					arr << cc
				end
			end			
			arr
		end

		def traverse(&op)
			op.call(self)
			all_children_deep.each do |c|
				op.call(c)
			end
		end

		def collect_values_with_count
			values = Hash.new {|h,k| h[k]=0}
			self.class.ecore.eAllAttributes.each do |a|
				v = self.send(:"#{a.name}")
				if v!=nil
					if a.many
						v.each {|el| values[el]+=1}
					else
						values[v]+=1
					end
				end
			end
			values			
		end

		def collect_values_with_count_subtree
			values = collect_values_with_count
			all_children_deep.each do |c|
				c.collect_values_with_count.each do |k,v|
					values[k]+=v
				end
			end
			values
		end		

		def all_children_of_type(type)
			all_children.select {|c| c and c.is_a?(type)}
		end

		def all_children_deep_of_type(type)
			all_children_deep.select {|c| c and c.is_a?(type)}
		end

		def only_child_of_type(type)
			selected = all_children_of_type(type)
			raise "Exactly one child of type #{type} expected, #{selected.count} found on #{self}" unless selected.count==1
			selected[0]
		end

		def only_child_deep_of_type(type)
			selected = all_children_deep_of_type(type)
			raise "Exactly one child of type #{type} expected, #{selected.count} found on #{self}" unless selected.count==1
			selected[0]
		end

	end

	module HostLineAddOn

		def host_start_line
			line_referred_to_host(self,self.source.begin_pos.line)				
		end

		def host_end_line
			line_referred_to_host(self,self.source.end_pos.line)
		end

		private

		def offset_referred_to_host(node)
			base = node.eContainer ? offset_referred_to_host(node.eContainer) : 0
			if node.eContainingFeature && node.eContainingFeature==:foreign_asts
				base+node.eContainer.source.begin_pos.line-1
			else
				base
			end
		end

		def line_referred_to_host(node,line)
			offset_referred_to_host(node)+line
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
	include HostLineAddOn
end
