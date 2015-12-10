require 'test_helper'

class ClouderaManager::RestartStrategyTest < Minitest::Test

  def setup
    super
    Kernel.stubs(:sleep)
    @failed_bulk_command = ClouderaManager::BulkCommand.new({success: false, active: false})
    @service = mock('Service')
    @service.responds_like(ClouderaManager::Service.new(name: "hdfs"))
    @service.stubs(:name).returns("hdfs")
  end

  def test_one_at_a_time_restart_strategy_runs_on_no_role_instances_for_a_service
    @service.expects(:restartable_role_names_for_type).with('NAMENODE').returns([])

    @strategy = ClouderaManager::RestartStrategy::OneAtATimeRestartStrategy.new(@service, 'NAMENODE', 5)
    commands = @strategy.run
    assert commands.size == 0
  end

  def test_one_at_a_time_restart_strategy_restarts_one_role_instance_at_a_time
    @service.expects(:restartable_role_names_for_type).with('NAMENODE').returns(['namenode-a', 'namenode-b'])
    @service.expects(:restart_role_instances!).with(['namenode-a']).returns(bulk_command)
    @service.expects(:restart_role_instances!).with(['namenode-b']).returns(bulk_command)

    @strategy = ClouderaManager::RestartStrategy::OneAtATimeRestartStrategy.new(@service, 'NAMENODE', 5)
    commands = @strategy.run
    assert_equal 2, commands.size
    assert commands.success
  end

  def test_one_at_a_time_restart_strategy_raises_if_any_instance_fails_to_restart
    @service.expects(:restartable_role_names_for_type).with('NAMENODE').returns(['namenode-a', 'namenode-b'])
    @service.expects(:restart_role_instances!).with(['namenode-a']).returns(bulk_command)
    @service.expects(:restart_role_instances!).with(['namenode-b']).returns(bulk_command(0, 1))

    @strategy = ClouderaManager::RestartStrategy::OneAtATimeRestartStrategy.new(@service, 'NAMENODE', 5)
    assert_raises(ClouderaManager::RestartStrategy::RestartFailedException) do
      @strategy.run
    end
  end

  def test_batched_restart_strategy_runs_on_no_role_instances_for_a_service
    @service.expects(:restartable_role_names_for_type).with('DATANODE').returns([])

    @strategy = ClouderaManager::RestartStrategy::BatchedRestartStrategy.new(@service, 'DATANODE', 5)
    commands = @strategy.run
    assert_equal 0, commands.size
  end

  def test_batched_restart_strategy_restarts_roles_in_batches_of_batch_size_for_a_service_with_many_instances_and_reports_success
    @service.expects(:restartable_role_names_for_type).with('DATANODE').returns(('a'..'h').map {|l| "datanode-#{l}"})
    @service.expects(:restart_role_instances!).with(['datanode-a', 'datanode-b', 'datanode-c']).returns(bulk_command(3))
    @service.expects(:restart_role_instances!).with(['datanode-d', 'datanode-e', 'datanode-f']).returns(bulk_command(3))
    @service.expects(:restart_role_instances!).with(['datanode-g', 'datanode-h']).returns(bulk_command(2))

    @strategy = ClouderaManager::RestartStrategy::BatchedRestartStrategy.new(@service, 'DATANODE', 3)
    commands = @strategy.run
    assert_equal 8, commands.size
    assert commands.success
  end

  def test_batched_restart_strategy_allows_less_than_ten_percent_of_commands_to_fail
    @service.expects(:restartable_role_names_for_type).with('DATANODE').returns(('a'..'u').map {|l| "datanode-#{l}"})
    @service.expects(:restart_role_instances!).with(('a'..'j').map {|l| "datanode-#{l}"}).returns(bulk_command(9,1))
    @service.expects(:restart_role_instances!).with(('k'..'t').map {|l| "datanode-#{l}"}).returns(bulk_command(9,1))
    @service.expects(:restart_role_instances!).with(["datanode-u"]).returns(bulk_command(1))

    @strategy = ClouderaManager::RestartStrategy::BatchedRestartStrategy.new(@service, 'DATANODE', 10)
    commands = @strategy.run
    assert_equal 21, commands.size
    assert_equal 2, commands.failed.size
    assert commands.success_ratio > 0.1
  end

  private

  def bulk_command(successes = 1, fails = 0)
    command = ClouderaManager::BulkCommand.new
    successes.times { command << ClouderaManager::Command.new({success: true, active: false, name: "Restart", resultMessage: "Thing restarted successfully"}) }
    fails.times { command << ClouderaManager::Command.new({success: false, active: false, name: "Restart", resultMessage: "Thing didn't restart!"}) }
    command
  end
end
