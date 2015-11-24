require 'her'
require 'cloudera-manager/middleware/url_prefix'
require 'cloudera-manager/middleware/json_parser'
require 'cloudera-manager/middleware/json_serializer'

module ClouderaManager
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
      end
    end

    def api
      @api ||= Her::API.new
    end

    def setup(options, &blk)
      username = options.delete(:username)
      password = options.delete(:password)

      api.setup(options) do |conn|
        conn.use Her::Middleware::AcceptJSON
        conn.use ClouderaManager::Middleware::URLPrefix, '/api/v10'
        conn.use ClouderaManager::Middleware::JSONParser
        conn.use ClouderaManager::Middleware::JSONSerializer
        conn.use Faraday::Response::RaiseError
        conn.basic_auth username, password
        conn.adapter Faraday.default_adapter
        blk.call(conn) if blk
      end
    end
  end

  class BaseException < Exception; end
end

require 'cloudera-manager/logging'
require 'cloudera-manager/base_resource'
require 'cloudera-manager/tool'
require 'cloudera-manager/host'
require 'cloudera-manager/service'
require 'cloudera-manager/cluster'
require 'cloudera-manager/role'
require 'cloudera-manager/command_actions'
require 'cloudera-manager/command'
require 'cloudera-manager/bulk_command'
