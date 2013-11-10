# encoding: utf-8
require 'test_helper'

class TestParser < Test::Unit::TestCase

	module Metamodel

		class SimpleText < CodeModels::CodeModelsAstNode
			has_attr 'text', String
		end
	end

	class SimpleTextParser < CodeModels::Parser

		def internal_parse_artifact(artifact)
			Metamodel::SimpleText.build(artifact.code)
		end

	end

	def test_encoding
		text1 = "Füße laissé fenêtre Miško Minár ă î Timișoara"
		# ISO 8859-1 does not support all characters, so it is shorter
		# then other examples
		text2 = "Füße laissé fenêtre"

		text_utf8       = SimpleTextParser.new.parse_file('test/data/text_utf8','UTF-8').text
		text_utf16le    = SimpleTextParser.new.parse_file('test/data/text_utf16LE','UTF-16LE').text
		text_utf16be    = SimpleTextParser.new.parse_file('test/data/text_utf16BE','UTF-16BE').text
		text_iso8859_1  = SimpleTextParser.new.parse_file('test/data/text_iso_8859_1', 'ISO-8859-1').text
		
		# ISO 8859 16 seems to be not fully supported in
		# Ruby 1.9 and JRuby 1.7, while it is in Ruby 2.0
		# This part of the test will be re-enabled later

		#text_iso8859_16 = SimpleTextParser.new.parse_file('test/data/text_iso_8859_16','ISO-8859-16')
	
		assert_equal text1,text_utf8
		assert_equal text1,text_utf16le
		assert_equal text1,text_utf16be
		assert_equal text2,text_iso8859_1
		
		#assert_equal text1,text_iso8859_16
	end

end