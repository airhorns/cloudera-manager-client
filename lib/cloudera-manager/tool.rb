module ClouderaManager
  class Tool < BaseResource
    def self.echo(message)
      find("echo", message: message)['message']
    end
  end
end
