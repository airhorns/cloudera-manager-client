module ClouderaManager
  module RestartStrategy
    class RestartFailedException < BaseException; end

    def self.determine(service, role_type, bulk_batch_size)
      klass = case role_type
      when "NODEMANAGER", "DATANODE", "IMPALAD"
        BatchedRestartStrategy
      else
        OneAtATimeRestartStrategy
      end
      klass.new(service, role_type, bulk_batch_size)
    end

    class BaseRestartStrategy
      include Logging

      def initialize(service, role_type, bulk_batch_size)
        @service = service
        @role_type = role_type
        @bulk_batch_size = bulk_batch_size
      end
    end

    class BatchedRestartStrategy < BaseRestartStrategy
      def run
        all_commands = ClouderaManager::BulkCommand.new

        @service.restartable_role_names_for_type(@role_type).each_slice(@bulk_batch_size) do |slice|
          logger.info "Restarting #{slice.join(', ')}"
          commands = @service.restart_role_instances!(slice)

          if commands.failed.size > 0
            logger.warn "Restart of #{commands.failed.map(&:name).join(', ')} all failed!"
          end
          if commands.success_ratio < 0.1
            raise RestartFailedException.new("Too many commands failed to execute successfully during restart of #{@role_type} on #{@service.name}, aborting!")
          end

          all_commands.concat(commands)
          Kernel.sleep 20  # always sleep between restarting batches to give time for previous services to initialize and connect
        end

        all_commands
      end
    end

    class OneAtATimeRestartStrategy < BaseRestartStrategy
      def run
        @service.restartable_role_names_for_type(@role_type).each_with_object(ClouderaManager::BulkCommand.new) do |role_instance, all_commands|
          logger.info "Restarting #{role_instance}"
          commands = @service.restart_role_instances!([role_instance])

          if commands.failed.size > 0
            raise RestartFailedException.new("Restarting #{role_instance} failed during restart of #{@role_type} on #{@service.name}, aborting!")
          end

          all_commands.concat(commands)
          Kernel.sleep 20  # always sleep between restarting batches to give time for previous services to initialize and connect
        end
      end
    end
  end
end
