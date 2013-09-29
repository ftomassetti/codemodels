# This module permits to manipulate Objects serialized
# as Hash

module CodeModels

module QuerySerialized

	def self.rel_conts(root)
		root.keys.select {|k| k.start_with? 'relcont_'}
	end

	def self.rel_non_conts(root)
		root.keys.select {|k| k.start_with? 'relnoncont_'}
	end

	def self.attrs(root)
		root.keys.select {|k| k.start_with? 'attr_'}
	end

	def self.print_tree(root,depth=0)
		traverse(root) do |n,d|
			s = ""
			d.times { s = s + "  " }
			s = s + n['type'] if n
			s = s + '<NIL>' unless n
			puts s
		end
	end	

	def self.values(root,feat)
		raw = root[feat]
		return [] if raw==nil
		return raw if raw.is_a? Array
		return [raw]
	end

	def self.traverse(root,depth=0,&op)
		return traverse(root['root'],depth,&op) if root and (root.key? 'root')
		op.call(root,depth)
		return unless root		
		rel_conts(root).each do |r|
			if root[r].is_a? Array
				root[r].each do |c|
					raise "expected an object but it is a #{c.class} (relation: #{r})" unless c.is_a? Hash
					traverse(c,depth+1,&op)
				end
			else
				traverse(root[r],depth+1,&op)
			end
		end
	end

	# the set of values appearing in the object and its children
	def self.collect_values(el)
		values = Set.new
		rel_conts(el).each do |r|
			values(el,r).each {|c| values.merge(collect_values(c))}
		end
		attrs(el).each do |a|
			values(el,a).each {|v| values.add(v)}
		end
		values
	end

	# a counting map values appearing in the object and its children
	def self.collect_values_with_count(el)
		values = Hash.new {|h,k| h[k]=0}
		rel_conts(el).each do |r|
			values(el,r).each do |ch| 
				collect_values_with_count(ch).each {|v,count| values[v]+=count}
			end
		end
		attrs(el).each do |a|
			values(el,a).each {|v| values[v]+=1 }
		end
		values
	end

end

end