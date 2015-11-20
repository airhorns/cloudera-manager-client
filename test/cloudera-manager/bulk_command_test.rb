require 'test_helper'

class ClouderaManager::BulkCommandTest < Minitest::Test

  def setup
    super
    @bulk_command = ClouderaManager::BulkCommand.new({success: true}, {success: true})
  end

  def test_success_needs_all_inner_commands_to_be_successful
    assert @bulk_command.success
    @bulk_command << ClouderaManager::Command.new(success: false)
    assert !@bulk_command.success
    assert !ClouderaManager::BulkCommand.new.success
  end
end
