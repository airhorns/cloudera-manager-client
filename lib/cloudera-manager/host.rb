module ClouderaManager
  class Host < BaseResource
    class HostNotFoundException < Exception; end

    primary_key :hostId

    class << self
      def find_by_hostname(hostname)
        if host = all.to_a.find {|host| host.hostname == hostname }
          return host
        else
          raise HostNotFoundException.new("Hostname #{hostname} could not be found remotely")
        end
      end

      def hadoopy?(hostname)
        all.any? {|host| host.hostname == hostname }
      end
    end

    def enter_maintenance_mode!
      remote_command! 'commands/enterMaintenanceMode'
    end

    def exit_maintenance_mode!
      remote_command! 'commands/exitMaintenanceMode'
    end
  end
end
