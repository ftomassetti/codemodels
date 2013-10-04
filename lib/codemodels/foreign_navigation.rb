module CodeModels

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
	values = node.collect_values_with_count
	all_children_deep_also_foreign(node).each do |c|
		c.collect_values_with_count.each do |k,v|
			values[k]+=v
		end
	end
	values	
end

end