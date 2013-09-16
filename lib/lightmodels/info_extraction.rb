module LightModels

module InfoExtraction

class TermsBreaker

	attr_accessor :sequences, :inv_sequences

	def initialize(language_specific_logic)
		@language_specific_logic = language_specific_logic
		@sequences = Hash.new {|h,k| 
			h[k] = Hash.new {|h,k| 
				h[k]=0
			} 
		}
		@inv_sequences = Hash.new {|h,k| 
			h[k] = Hash.new {|h2,k2| 
				h2[k2]=0
			} 
		}
	end

	def self.from_context(language_specific_logic,context)
		ser_context = LightModels::Serialization.jsonize_obj(context)
		values_map = LightModels::Query.collect_values_with_count(ser_context)
		instance = new(language_specific_logic)	
		values_map.each do |value,c|
			value = value.to_s.strip
			if language_specific_logic.terms_containing_value?(value)
				words = language_specific_logic.to_words(value)				
				first_words = words[0...-1]
				#puts "Recording that #{first_words[0]} is preceeded by #{:start} #{c} times"
				instance.inv_sequences[words[0].downcase][:start] += c
				first_words.each_with_index do |w,i|
					instance.sequences[w.downcase][words[i+1].downcase] += c
					instance.inv_sequences[words[i+1].downcase][w.downcase] += c
				end
				last_word = words.last
				instance.sequences[last_word.downcase][:end] += c
			else
				# who cares, it will be never considered for composed names...
			end
		end
		instance
	end

	def frequent_straight_sequence?(w1,w2)
		w1 = w1.downcase
		w2 = w2.downcase
		all_sequences_of_w1 = 0
		@sequences[w1].each do |k,v|
			all_sequences_of_w1 += v
		end
		sequences_w1_w2 = @sequences[w1][w2]
		(sequences_w1_w2.to_f/all_sequences_of_w1.to_f)>0.5
	end

	def frequent_inverse_sequence?(w1,w2)
		w1 = w1.downcase
		w2 = w2.downcase
		#puts "Inverse sequences of #{w1}-#{w2}"
		all_inv_sequences_of_w1 = 0
		@inv_sequences[w1].each do |k,v|
			#puts "\tpreceeded by #{k} #{v} times"
			all_inv_sequences_of_w1 += v
		end
		inv_sequences_w1_w2 = @inv_sequences[w1][w2]
		(inv_sequences_w1_w2.to_f/all_inv_sequences_of_w1.to_f)>0.5
	end

	def frequent_sequence?(w1,w2)
		return false unless w2
		#puts "Checking if #{w1}-#{w2} is freq sequence:"
		#puts "\tstraight: #{frequent_straight_sequence?(w1,w2)}"
		#puts "\tinverse: #{frequent_inverse_sequence?(w2,w1)}"
		frequent_straight_sequence?(w1,w2) && frequent_inverse_sequence?(w2,w1)
	end

	def terms_in_value(value)
		value = value.to_s.strip
		if @language_specific_logic.terms_containing_value?(value)
			words = @language_specific_logic.to_words(value)
			group_words_in_terms(words).map{|w| w.downcase}			
		else
			[value]
		end
	end

	def group_words_in_terms(words)
		# getNotSoGoodFieldName is not a term because
		# notSoGoodFieldName is more frequently alone that preceded by get

		return words if words.count==1
		start_term = 0
		end_term   = 0
		term       = words[0]
		while end_term < words.count && frequent_sequence?(words[end_term],words[end_term+1])
			end_term += 1
			term += words[end_term]
		end
		return [term] if end_term==(words.count-1)
		#puts "Words #{words.count}"
		#puts "End term: #{end_term}"
		[term] + group_words_in_terms(words[(end_term+1)..-1])
	end

end

def self.values_map(model_node)
	ser_model_node = LightModels::Serialization.jsonize_obj(model_node)
	LightModels::Query.collect_values_with_count(ser_model_node)
end

def self.terms_map(language_specific_logic,model_node,context=nil)
	# context default to root
	unless context
		context = model_node
		while context.eContainer
			context = context.eContainer
		end		
	end

	# look into context to see how frequent are certain series of words,
	# frequent series are recognized as composed terms
	terms_breaker = TermsBreaker.from_context(language_specific_logic,context)

	
	values_map = values_map(model_node)
	#puts "values #{values_map}"
	terms_map = Hash.new {|h,k| h[k]=0}
	values_map.each do |v,n|
		terms_breaker.terms_in_value(v).each do |t|
			terms_map[t] += n
		end
	end
	terms_map
end

end

end