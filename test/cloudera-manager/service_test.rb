require 'test_helper'

class ClouderaManager::ServiceTest < RemoteTest

  def setup
    super
    Kernel.stubs(:sleep)
    @services = ClouderaManager::Cluster.find("cluster").services.to_a
    @oozie = @services.find {|s| s.name == "oozie1" }
    @yarn = @services.find {|s| s.name == "yarn" }
    @impala = @services.find {|s| s.name == "impala" }
  end

  def test_role_types_can_be_retrieved
    assert_equal ["OOZIE_SERVER"], @oozie.role_types
  end

  def test_restartable_role_names_for_type_retrieves_all_instances_of_a_role_type
    assert_equal ["oozie1-OOZIE_SERVER-41b880ae9c2aa2a0d063deb54639716d"], @oozie.restartable_role_names_for_type("OOZIE_SERVER")
    assert_equal ["yarn-RESOURCEMANAGER-5068bde938639b7bf18f7da78d115e78", "yarn-RESOURCEMANAGER-f233fbd2528abacef733931b726d9884"], @yarn.restartable_role_names_for_type("RESOURCEMANAGER")
  end

  def test_rolling_restart_restarts_each_role_type_instance_in_groups_of_batch_size
    commands = @impala.rolling_restart!(5)
    assert commands.finished?
    assert commands.success
    @impala.refresh
    assert "STARTED", @impala.serviceState
  end
end
