module LightModels

module Stats

def self.entropy(counting_map)
	s = 0.0	
	counting_map.each do |k,v|
		p = counting_map.p(k)
		s += p*Math.log(p)
	end
	-s
end

def idf(n,n_docs)
	Math.log(n_docs.to_f/n.to_f)
end

def combine_self(arr,&op)
	for i in 0..(arr.count-2)
		for j in (i+1)..(arr.count-1)
			op.call(arr[i],arr[j])
		end
	end
end

def combine(arr1,arr2,&op)
	arr1.each do |el1|
		arr2.each {|el2| op.call(el1,el2)}
	end
end

end

end
