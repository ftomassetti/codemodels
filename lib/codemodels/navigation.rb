# encoding: UTF-8
module CodeModels

# The flag :also_foreign deciced if to consider the 
# AST of embedded code
module NavigationExtensions

	# All direct children
	def all_children(flag=nil)
		also_foreign = (flag==:also_foreign)
		arr = []
		ecore = self.class.ecore
		# Awful hack to forbid the same reference is visited twice when
		# two references with the same name are found
		already_used_references = []
		ecore.eAllReferences.sort_by{|r| r.name}.select {|r| r.containment}.each do |ref|
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
		if also_foreign
			arr.concat(self.foreign_asts)
		end
		arr
	end

	# All direct and indirect children
	def all_children_deep(flag=nil)
		arr = []
		all_children(flag).each do |c|
			arr << c
			c.all_children_deep(flag).each do |cc|
				arr << cc
			end
		end			
		arr
	end

	# Execute an operation on the node itself and all children,
	# direct and indirect.
	def traverse(flag=nil,&op)
		op.call(self)
		all_children_deep(flag).each do |c|
			op.call(c)
		end
	end

	# All the values considering the node, 
	# and the direct and indirect children (if :deep is contained in flags).
	# In that case the presence of :also_foreign determine if also embedded
	# ASTs are considrered
	def values_map(flags=nil)
		raise ":also_foreign makes sense only when :deep is used" if flags.include?(:also_foreign) && !flags.include?(:deep)
		if flags.include?(:deep)
			collect_values_with_count_subtree(flags.include?(:also_foreign)?(:also_foreign):nil)
		else
			collect_values_with_count
		end
	end

	# Deprecated, use values_map instead
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

	# Deprecated, use values_map instead
	def collect_values_with_count_subtree(flag=nil)
		values = collect_values_with_count
		all_children_deep(flag).each do |c|
			c.collect_values_with_count.each do |k,v|
				values[k]+=v
			end
		end
		values
	end		

	def all_children_of_type(flag=nil,type)
		all_children(flag).select {|c| c and c.is_a?(type)}
	end

	def all_children_deep_of_type(flag=nil,type)
		all_children_deep(flag).select {|c| c and c.is_a?(type)}
	end

	def only_child_of_type(flag=nil,type)
		selected = all_children_of_type(flag,type)
		raise "Exactly one child of type #{type} expected, #{selected.count} found on #{self}" unless selected.count==1
		selected[0]
	end

	def only_child_deep_of_type(flag=nil,type)
		selected = all_children_deep_of_type(flag,type)
		raise "Exactly one child of type #{type} expected, #{selected.count} found on #{self}" unless selected.count==1
		selected[0]
	end

	# Parent of the node.
	# A foreign child could have its own parent in the foreign ast, which is not part of the complexive AST
	# the foreign parent has therefore the precedence.
	def container(flag=nil)
		also_foreign = (flag==:also_foreign)		
		if also_foreign && self.foreign_container
			return self.foreign_container
		else
			return self.eContainer
		end
	end

	def root(flag=nil)
		return self unless self.container(flag)
		self.container(flag).root(flag)
	end

	def all_children_also_foreign
		all_children(:also_foreign)
	end

	def all_children_deep_also_foreign
		all_children_deep(:also_foreign)
	end		

	# Deprecated
	def traverse_also_foreign(&block)
		traverse(:also_foreign,&block)
	end

	# Deprecated
	def container_also_foreign
		container(:also_foreign)
	end

end

end