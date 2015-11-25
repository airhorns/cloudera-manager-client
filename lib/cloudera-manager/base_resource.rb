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

    def remote_command!(method, path_segment)
      command = nil
      self.class.request(_method: method, _path: File.join(request_path, path_segment)) do |parsed_data, response|
        command = Command.new(parsed_data[:data])
        return command if !response.success? || !command.success || @response_errors.any?
      end
      refresh
      command
    end
  end
end
