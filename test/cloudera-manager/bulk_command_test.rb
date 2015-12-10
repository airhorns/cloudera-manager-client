require 'test_helper'

class ClouderaManager::BulkCommandTest < Minitest::Test

  def setup
    super
    @bulk_command = ClouderaManager::BulkCommand.new({success: true, active: false}, {success: true, active: false})
  end

  def teardown
    Timecop.return
  end

  def test_success_needs_all_inner_commands_to_be_successful
    assert @bulk_command.success
    @bulk_command << ClouderaManager::Command.new(success: false)
    assert !@bulk_command.success
    assert !ClouderaManager::BulkCommand.new.success
  end

  def test_finished_reports_if_all_commands_are_no_longer_active
    assert @bulk_command.finished?
    @bulk_command << ClouderaManager::Command.new(success: false, active: false)
    assert @bulk_command.finished?
    @bulk_command << ClouderaManager::Command.new(active: true)
    assert !@bulk_command.finished?
  end

  def test_success_ratio_reports_how_many_commands_out_of_the_set_were_successful
    assert_equal 1, @bulk_command.success_ratio
    @bulk_command << ClouderaManager::Command.new(success: false, active: false)
    @bulk_command << ClouderaManager::Command.new(success: false, active: false)
    assert_equal 0.5, @bulk_command.success_ratio
  end

  def test_success_ratio_only_considers_finished_commands
    assert_equal 1, @bulk_command.success_ratio
    @bulk_command << ClouderaManager::Command.new(success: false, active: true)
    assert_equal 1, @bulk_command.success_ratio
  end

  def test_success_ratio_for_an_empty_command_set_is_zero_for_no_good_reason
    assert_equal 0, ClouderaManager::BulkCommand.new.success_ratio
  end

  def test_failed_returns_only_the_finished_and_unsuccessful_commands
    assert_equal [], @bulk_command.failed
    command = ClouderaManager::Command.new(success: false, active: true)

    @bulk_command << command
    assert_equal [], @bulk_command.failed

    command.active = false
    assert_equal [command], @bulk_command.failed
  end

  def test_block_until_outcome_returns_the_success_status_immediately_if_all_commands_are_complete
    assert @bulk_command.block_until_outcome
  end

  def test_block_until_outcome_waits_for_any_outstanding_commands_to_be_complete_before_returning
    command = ClouderaManager::Command.new(active: true, success: true)
    @bulk_command << command

    @bulk_command.each { |command| command.stubs(:refresh).returns(true) }
    command.expects(:finished?).times(3).returns(false, false, true)
    Kernel.expects(:sleep).with(1).times(2).returns(true)

    assert @bulk_command.block_until_outcome
  end

  def test_block_until_outcome_times_out_after_120_seconds_if_a_command_hasnt_completed
    command = ClouderaManager::Command.new(active: true, success: true)
    @bulk_command << command

    @bulk_command.each { |command| command.stubs(:refresh).returns(true) }

    start_time = Time.now
    count = 0
    Mocha.with_callable_returns do
      Kernel.expects(:sleep).with(1).times(121).returns -> {
        Timecop.freeze(start_time + (count += 1))
      }
    end

    assert_raises ClouderaManager::CommandActions::CommandTimeoutException do
      @bulk_command.block_until_outcome
    end
  end
end
