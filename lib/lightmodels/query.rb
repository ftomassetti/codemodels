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

end

end