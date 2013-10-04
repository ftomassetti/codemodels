module CodeModels

class AbstractNavigation

	def all_children_deep(node)
		arr = []
		all_children(node).each do |c|
			arr << c
			arr.concat(all_children_deep(node))
		end			
		arr		
	end	

	def traverse(node,&block)
		[node].concat(all_children_deep(node)).each do |n|
			block.call(n)
		end
	end	

end

class NavigationExcludingForeign < AbstractNavigation

	def container(node)
		node.eContainer
	end

	def all_children(node)
		node.all_children
	end	

end

class NavigationIncludingForeign < AbstractNavigation

	def container(node)
		return node.eContainer if node.eContainer
		node.foreign_container
	end

	def all_children(node)
		node.all_children.concat(node.foreign_asts)
	end

end

def self.container_also_foreign(node)
	return node.eContainer if node.eContainer
	return node.foreign_container
end

def self.all_children_also_foreign(node)
	node.all_children.concat(node.foreign_asts)
end

def self.all_children_deep_also_foreign(node)
	arr = []
	all_children_also_foreign(node).each do |c|
		arr << c
		arr.concat(all_children_deep_also_foreign(c))
	end			
	arr
end

def self.traverse_also_foreign(node,&block)
	[node].concat(all_children_deep_also_foreign(node)).each do |n|
		block.call(n)
	end
end

def self.collect_values_with_count_subtree_also_foreign(node)
	values = []
	traverse_also_foreign(node) do |n|
		n.collect_values_with_count.each { |k,v| values[k]+=v }
	end
	values	
end

end