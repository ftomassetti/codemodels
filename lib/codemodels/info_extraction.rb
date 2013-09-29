require 'rgen/metamodel_builder'

module CodeModels
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
		values_map = context.values_map
		instance = new(language_specific_logic)	
		values_map.each do |value,c|
			value = value.to_s.strip
			if language_specific_logic.terms_containing_value?(value)
				words = language_specific_logic.to_words(value)				
				first_words = words[0...-1]
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

	def terms_in_value(value)
		value = value.to_s.strip
		if @language_specific_logic.terms_containing_value?(value)
			words = @language_specific_logic.to_words(value)
			group_words_in_terms(words).map{|w| w.downcase}			
		else
			[value]
		end
	end

	private

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
		all_inv_sequences_of_w1 = 0
		@inv_sequences[w1].each do |k,v|
			all_inv_sequences_of_w1 += v
		end
		inv_sequences_w1_w2 = @inv_sequences[w1][w2]
		(inv_sequences_w1_w2.to_f/all_inv_sequences_of_w1.to_f)>0.5
	end

	def frequent_sequence?(w1,w2)
		return false unless w2
		frequent_straight_sequence?(w1,w2) && frequent_inverse_sequence?(w2,w1)
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
			term = @language_specific_logic.concat(term,words[end_term])
		end
		return [term] if end_term==(words.count-1)
		[term] + group_words_in_terms(words[(end_term+1)..-1])
	end

end

module InfoExtractionFunctionalities

	def values_map
		collect_values_with_count_subtree
	end

	def terms_map(language_specific_logic,context=nil)
		# context default to root
		unless context
			context = self
			while context.eContainer
				context = context.eContainer
			end		
		end

		# look into context to see how frequent are certain series of words,
		# frequent series are recognized as composed terms
		terms_breaker = TermsBreaker.from_context(language_specific_logic,context)

		v_map = self.values_map
		terms_map = Hash.new {|h,k| h[k]=0}
		v_map.each do |v,n|
			terms_breaker.terms_in_value(v).each do |t|
				terms_map[t] += n
			end
		end
		terms_map
	end

end

class ::RGen::MetamodelBuilder::MMBase
	include InfoExtractionFunctionalities
end

end
end