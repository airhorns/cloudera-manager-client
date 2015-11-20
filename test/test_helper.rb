$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler'
Bundler.require(:default, :development)
require 'cloudera-manager-client'

url = ENV['CLOUDERA_MANAGER_URI'] || "http://hadoop.com:7111"
username = ENV['CLOUDERA_MANAGER_USER'] || "admin"
password = ENV['CLOUDERA_MANAGER_PASSWORD'] || "password"
ClouderaManager.setup url: url , username: username, password: password

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
end

class RemoteTest < Minitest::Test
  def setup
    super
    VCR.insert_cassette name
  end

  def teardown
    super
    VCR.eject_cassette
  end

end
require 'minitest/autorun'
