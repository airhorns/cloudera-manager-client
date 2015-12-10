require 'test_helper'

class ClouderaManager::RestartStrategyRemoteTest < RemoteTest

  def setup
    super
    Kernel.stubs(:sleep)
    @services = ClouderaManager::Cluster.find("cluster").services.to_a
    @oozie = @services.find {|s| s.name == "oozie1" }
    @yarn = @services.find {|s| s.name == "yarn" }
    @impala = @services.find {|s| s.name == "impala" }
  end

  def test_rolling_restart_of_type_restarts_each_role_instance_in_a_single_instance_service
    commands = @oozie.rolling_restart_of_type!("OOZIE_SERVER", 1)
    assert commands.finished?
    assert commands.success
    @oozie.refresh
    assert "STARTED", @oozie.serviceState
  end

  def test_rolling_restart_of_type_aborts_if_one_role_type_cant_be_restarted
    # doctored fixture causes raise
    assert_raises(ClouderaManager::Service::RestartFailedException) do
      @oozie.rolling_restart_of_type!("OOZIE_SERVER", 1)
    end
  end

  def test_rolling_restart_restarts_role_types_in_order_if_an_order_is_hardcoded
    restart = sequence('restart')

    @yarn.expects(:rolling_restart_of_type!).with("JOBHISTORY", 1).in_sequence(restart).returns(ClouderaManager::BulkCommand.new)
    @yarn.expects(:rolling_restart_of_type!).with("NODEMANAGER", 5).in_sequence(restart).returns(ClouderaManager::BulkCommand.new)
    @yarn.expects(:rolling_restart_of_type!).with("RESOURCEMANAGER", 1).in_sequence(restart).returns(ClouderaManager::BulkCommand.new)
    @yarn.rolling_restart!(5)
  end

  def test_rolling_restart_restarts_roles_types_in_whatever_order_if_the_order_isnt_hardcoded
    @hive = @services.find {|s| s.name == "hive" }
    restart = sequence('restart')
    @hive.expects(:rolling_restart_of_type!).with("GATEWAY", 1).in_sequence(restart).returns(ClouderaManager::BulkCommand.new)
    @hive.expects(:rolling_restart_of_type!).with("HIVEMETASTORE", 1).in_sequence(restart).returns(ClouderaManager::BulkCommand.new)
    @hive.expects(:rolling_restart_of_type!).with("WEBHCAT", 1).in_sequence(restart).returns(ClouderaManager::BulkCommand.new)
    @hive.expects(:rolling_restart_of_type!).with("HIVESERVER2", 1).in_sequence(restart).returns(ClouderaManager::BulkCommand.new)
    @hive.rolling_restart!(5)
  end
end
