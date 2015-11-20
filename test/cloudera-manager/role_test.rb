require 'test_helper'

class ClouderaManager::RoleTest < RemoteTest

  def setup
    super
    @oozie = ClouderaManager::Cluster.find("cluster").services.to_a.find {|s| s.name == "oozie1" }
  end

  def test_roles_can_be_fetched_despite_their_ridiculously_long_path
    first_role_name = @oozie.roles.to_a.first.name # get at the role via associations to build up a path using other code
    role = ClouderaManager::Role.find(first_role_name, _cluster_id: "cluster", _service_id: "oozie1")
    assert_equal first_role_name, role.name
  end
end
