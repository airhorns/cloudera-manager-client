
require 'test_helper'

class ClouderaManager::CommandTest < Minitest::Test

  def setup
    super
    @command = ClouderaManager::Command.new({success: true, active: false})
  end

  def teardown
    Timecop.return
  end

  def test_finished_reports_if_the_command_is_active_or_not
    assert @command.finished?

    assert ! ClouderaManager::Command.new({active: true}).finished?
  end

  def test_block_until_outcome_returns_the_success_status_immediately_if_all_commands_are_complete
    assert @command.block_until_outcome
  end

  def test_block_until_outcome_waits_for_the_command_to_complete_before_returning
    @command = ClouderaManager::Command.new(active: true, success: true)
    @command.stubs(:refresh).returns(true)
    @command.expects(:finished?).times(3).returns(false, false, true)
    Kernel.expects(:sleep).with(1).times(2).returns(true)

    assert @command.block_until_outcome
  end

  def test_block_until_outcome_times_out_after_120_seconds_if_the_command_hasnt_completed
    @command = ClouderaManager::Command.new(active: true, success: true)
    @command.stubs(:refresh).returns(true)

    start_time = Time.now
    count = 0
    Mocha.with_callable_returns do
      Kernel.expects(:sleep).with(1).times(121).returns -> {
        Timecop.freeze(start_time + (count += 1))
      }
    end

    assert_raises ClouderaManager::CommandActions::CommandTimeoutException do
      @command.block_until_outcome
    end
  end
end
