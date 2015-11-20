module ClouderaManager
  class BaseResource
    include Her::Model
    include Logging
    use_api ClouderaManager.api

    def refresh
      self.class.request(_method: :get, _path: request_path) do |parsed_data, response|
        assign_attributes(self.class.parse(parsed_data[:data])) if parsed_data[:data].any?
        @metadata = parsed_data[:metadata]
        @response_errors = parsed_data[:errors]
        return response.success? && !@response_errors.any?
      end
    end

    def remote_command!(path_segment, body = {})
      command = nil
      params = body.merge({_method: :post, _path: File.join(request_path, path_segment)})

      self.class.request(params) do |parsed_data, response|
        data = parsed_data[:data]
        command = if data.respond_to?(:to_hash)
          Command.new(data.to_hash)
        else
          BulkCommand.new(data)
        end
        refresh if response.success? && command.success
      end

      command
    end
  end
end
