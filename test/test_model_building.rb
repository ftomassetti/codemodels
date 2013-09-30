require 'test_helper'

class TestModelBuilding < Test::Unit::TestCase

include CodeModels

def test_file_mapper
	fm = FileMapper.new('dir_a','dir_b','java','xml')
	assert_equal "dir_b/abc/def/pippo.xml",fm.map('dir_a/abc/def/pippo.java')
end

end