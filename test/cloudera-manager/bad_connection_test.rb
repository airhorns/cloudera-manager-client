require 'test_helper'

class ClouderaManager::BadConnectionTest < RemoteTest
  def test_404_errors_are_raised
    assert_raises(Faraday::Error::ResourceNotFound) do
      ClouderaManager::Tool.request(_method: :get, _path: "bogus")
    end
  end
end
