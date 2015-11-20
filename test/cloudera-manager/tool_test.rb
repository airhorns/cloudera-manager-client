require 'test_helper'

class ClouderaManager::ToolTest < RemoteTest
  def test_messages_are_echoed
    assert_equal 'foo', ClouderaManager::Tool.echo('foo')
  end
end
