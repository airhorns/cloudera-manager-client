module ClouderaManager
  class Host < BaseResource

    primary_key :hostId

    def enter_maintenance_mode!
      remote_command! :post, 'commands/enterMaintenanceMode'
    end

    def exit_maintenance_mode!
      remote_command! :post, 'commands/exitMaintenanceMode'
    end
  end
end
