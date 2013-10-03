module CodeModels

def self.all_children_also_foreign(node)
	node.all_children.merge(node.foreign_asts)
end

def self.all_children_deep_also_foreign(node)
	arr = []
	all_children_also_foreign(n) do |c|
		arr << c
		arr.merge(all_children_deep_also_foreign(c))
	end			
	arr
end

def self.traverse_also_foreign(node,&block)
	[node].merge(all_children_deep_also_foreign(node)).each do |n|
		block.call(n)
	end
end

end