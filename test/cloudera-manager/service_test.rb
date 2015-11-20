require 'test_helper'

class ClouderaManager::ServiceTest < RemoteTest

  def setup
    super
    services = ClouderaManager::Cluster.find("cluster").services.to_a
    @oozie = services.find {|s| s.name == "oozie1" }
    @yarn = services.find {|s| s.name == "yarn" }
  end

  def test_role_types_can_be_retrieved
    assert_equal ["OOZIE_SERVER"], @oozie.role_types
  end
end
