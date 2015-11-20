require 'her'
require 'cloudera-manager/middleware/url_prefix'
require 'cloudera-manager/middleware/json_parser'
require 'cloudera-manager/middleware/json_serializer'

module ClouderaManager
  def self.api
    @api ||= Her::API.new
  end

  def self.setup(options, &blk)
    username = options.delete(:username)
    password = options.delete(:password)

    api.setup(options) do |conn|
      conn.use Her::Middleware::AcceptJSON
      conn.use ClouderaManager::Middleware::URLPrefix, '/api/v10'
      conn.use ClouderaManager::Middleware::JSONParser
      conn.use ClouderaManager::Middleware::JSONSerializer
      conn.basic_auth username, password
      conn.adapter Faraday.default_adapter
      blk.call(conn) if blk
    end
  end
end

require 'cloudera-manager/base_resource'
require 'cloudera-manager/tool'
require 'cloudera-manager/host'
require 'cloudera-manager/service'
require 'cloudera-manager/cluster'
require 'cloudera-manager/command'
