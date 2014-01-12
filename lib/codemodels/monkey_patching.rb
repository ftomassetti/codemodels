# encoding: UTF-8
class Module

  # If the name of contains a colon, it returns the part after the last colon
  def simple_name
    if (i = (r = name).rindex(':')) then r[0..i] = '' end
    r
  end
  
end

class String

	def remove_postfix(postfix)
		raise "'#{self}'' have not the right postfix '#{postfix}'" unless end_with?(postfix)
		self[0..-(1+postfix.length)]
	end

	def remove_prefix(prefix)
		raise "'#{self}'' have not the right prefix '#{prefix}'" unless start_with?(prefix)
		self[prefix.length..-1]
	end
	
	def proper_capitalize 
    	self[0, 1].upcase + self[1..-1]
  	end

	def proper_uncapitalize 
    	self[0, 1].downcase + self[1..-1]
  	end

end	