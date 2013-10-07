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

	ea3_pos = SourcePosition.new
	ea3_pos.begin_line = 1
	ea3_pos.begin_column = 2

	@fa1 = FileArtifact.new("pippo.txt","...code...")
	
	@ea1 = EmbeddedArtifact.new
	@ea1.host_artifact = @fa1
	@ea1.position_in_host = ea1_pos	
	
	@ea2 = EmbeddedArtifact.new
	@ea2.host_artifact = @ea1
	@ea2.position_in_host = ea2_pos

	@ea3 = EmbeddedArtifact.new
	@ea3.host_artifact = @ea2
	@ea3.position_in_host = ea3_pos	
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

def test_embedded_artifact_indirect_absolute_start_on_line_1
	sp = SourcePoint.new 12,5
	assert_equal sp,@ea3.absolute_start
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

def test_embedded_artifact_position_to_absolute
	p1b = SourcePoint.new 1,8
	p1e = SourcePoint.new 12,7
	pos1 = SourcePosition.new p1b,p1e
	p2b = SourcePoint.new 10,15
	p2e = SourcePoint.new 21,7
	pos2 = SourcePosition.new p2b,p2e
	assert_equal pos2,@ea1.position_to_absolute(pos1)
end

def test_source_point_begin_point_assignment_with_point
	p = SourcePoint.new 7,8
	si = SourceInfo.new
	si.begin_point = p
	assert_equal SourcePoint.new(7,8),si.position.begin_point
end

def test_source_point_end_point_assignment_with_hash
	si = SourceInfo.new
	si.end_point = {line:7,column:8}
	assert_equal SourcePoint.new(7,8),si.position.end_point
end

end