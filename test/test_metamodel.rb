require 'test_helper'

class TestMetamodel < Test::Unit::TestCase

include CodeModels

def setup
	@fa1 = FileArtifact.new
	@ea1 = EmbeddedArtifact.new
	@ea1.host_artifact = @fa1
	ea1_pos = SourcePosition.new
	ea1_pos.begin_line = 10
	ea1_pos.begin_column = 8
	@ea1.position_in_host = ea1_pos	
end

def test_file_artifact_absolute_start
	sp = SourcePoint.new
	sp.line = 1
	sp.column = 1
	assert_equal sp,@fa1.absolute_start
end

def test_embedded_artifact_absolute_start
	sp = SourcePoint.new
	sp.line = 10
	sp.column = 8
	assert_equal sp,@ea1.absolute_start
end

end