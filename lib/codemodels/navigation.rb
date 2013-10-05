module CodeModels

class CodeModelsAstNode

	module NavigationExtensions

		def all_children(flag=nil)
			also_foreign = (flag==:also_foreign)
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
			if also_foreign
				arr.concat(self.foreign_asts)
			end
			arr
		end

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

		def traverse(flag=nil,&op)
			op.call(self)
			all_children_deep(flag).each do |c|
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

		def container(flag=nil)
			also_foreign = (flag==:also_foreign)
			return self.eContainer if self.eContainer
			if also_foreign
				self.foreign_container
			else
				nil
			end
		end

		def all_children_also_foreign
			all_children(:also_foreign)
		end

		def all_children_deep_also_foreign
			all_children_deep(:also_foreign)
		end		

		def traverse_also_foreign(&block)
			traverse(:also_foreign,block)
		end

	end

	include NavigationExtensions

end

end