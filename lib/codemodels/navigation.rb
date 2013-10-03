module CodeModels

def self.all_children_also_foreign(node)
	node.all_children.concat(node.foreign_asts)
end

def self.all_children_deep_also_foreign(node)
	arr = []
	all_children_also_foreign(node) do |c|
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

end