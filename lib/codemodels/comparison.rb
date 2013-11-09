module CodeModels

module ComparisonModule

	def eql?(other)
		return false unless RGen::Ext::Comparison::DeepComparator.eql?(self,other)
		if self.respond_to?(:source) || other.respond_to?(:source)
			return false if (self.source==nil) != (other.source==nil)
			return true if self.source==nil
			return false if (self.source.position==nil) != (other.source.position==nil)				
			return true if self.source.position==nil
			return self.source.position(:absolute)==other.source.position(:absolute)
		end
		true
	end

	def ==(other)
		eql? other
	end

end

end