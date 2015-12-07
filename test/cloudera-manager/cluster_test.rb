require 'test_helper'

class ClouderaManager::ClusterTest < RemoteTest

  def test_cluster_can_be_retrieved
    @cluster = ClouderaManager::Cluster.find("cluster")
    assert_equal "cluster", @cluster.name
    assert_equal "CDH5", @cluster.version
  end

  def test_services_can_be_retrieved
    @cluster = ClouderaManager::Cluster.all.first
    services = @cluster.services
    assert services.map(&:name).include?("yarn")
  end

  def test_commands_can_be_retrieved
    @cluster = ClouderaManager::Cluster.find("cluster")
    commands = @cluster.commands
    assert_equal 1, commands.size
    assert_equal "RefreshCluster", commands[0].name
  end
end
