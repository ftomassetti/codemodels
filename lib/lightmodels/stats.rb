#require 'emf_jruby'

module LightModels

# DEPRECATED
class CountingMap

	def initialize
		@map = {}
		@sum_values = 0
	end

	def inc(key)
		@map[key] = 0 unless @map[key]
		@map[key] = @map[key]+1
		@sum_values += 1
	end

	def value(key)
		@map[key] = 0 unless @map[key]
		@map[key]
	end

	# number of times the value appeared divived by total frequency
	def p(key)
		@map[key].to_f/total_frequency.to_f
	end

	def each(&block)
		@map.each(&block)
	end

	def total_frequency
		@sum_values
	end

	def n_values
		@map.count
	end

end

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
