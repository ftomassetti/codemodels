require 'set'
require 'lightmodels/jsonser_nav'

module LightModels

module Query

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
		LightModels::Query.values(el,r).each do |ch| 
			collect_values_with_count(ch).each {|v,count| values[v]+=count}
		end
	end
	attrs(el).each do |a|
		LightModels::Query.values(el,a).each {|v| values[v]+=1 }
	end
	values
end

end

end