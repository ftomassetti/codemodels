require 'test_helper'

class TestMetamodel < Test::Unit::TestCase

include CodeModels

def setup
	ea1_pos = SourcePosition.new
	ea1_pos.begin_line = 10
	ea1_pos.begin_column = 8

	ea2_pos = SourcePosition.new
	ea2_pos.begin_line = 3
	ea2_pos.begin_column = 4

	@fa1 = FileArtifact.new
	
	@ea1 = EmbeddedArtifact.new
	@ea1.host_artifact = @fa1
	@ea1.position_in_host = ea1_pos	
	
	@ea2 = EmbeddedArtifact.new
	@ea2.host_artifact = @ea1
	@ea2.position_in_host = ea2_pos
end

def test_file_artifact_absolute_start
	sp = SourcePoint.new 1,1
	assert_equal sp,@fa1.absolute_start
end

def test_embedded_artifact_absolute_start
	sp = SourcePoint.new 10,8
	assert_equal sp,@ea1.absolute_start
end

def test_embedded_artifact_indirect_absolute_start
	sp = SourcePoint.new 12,4
	assert_equal sp,@ea2.absolute_start
end

def test_file_artifact_point_to_absolute
	p1 = SourcePoint.new 5,7
	p2 = SourcePoint.new 5,7
	assert_equal p2,@fa1.point_to_absolute(p1)
end

def test_embedded_artifact_point_to_absolute
	p1 = SourcePoint.new 5,7
	p2 = SourcePoint.new 14,7
	assert_equal p2,@ea1.point_to_absolute(p1)
	p3 = SourcePoint.new 1,7
	p4 = SourcePoint.new 10,14
	assert_equal p4,@ea1.point_to_absolute(p3)
end

def test_embedded_artifact_indirect_point_to_absolute
	p1 = SourcePoint.new 5,7
	p2 = SourcePoint.new 16,7
	assert_equal p2,@ea2.point_to_absolute(p1)
	p3 = SourcePoint.new 1,7
	p4 = SourcePoint.new 12,10
	assert_equal p4,@ea2.point_to_absolute(p3)	
end

end