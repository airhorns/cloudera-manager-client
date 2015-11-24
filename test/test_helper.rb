$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'bundler'
Bundler.require(:default, :development)
require 'mocha/mini_test'
require 'mocha_dynamic_return'
require 'remote_test'

require 'cloudera-manager-client'

ClouderaManager.setup({
  url:      ENV['CLOUDERA_MANAGER_URI'] || "http://hadoop.com:7111",
  username: ENV['CLOUDERA_MANAGER_USER'] || "admin",
  password: ENV['CLOUDERA_MANAGER_PASSWORD'] || "password"
})

ClouderaManager.logger.level = Logger::FATAL

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

require 'minitest/autorun'
