module ClouderaManager
  module CommandActions
    COMMAND_OUTCOME_TIMEOUT_SECONDS = 120
    POLL_INTERVAL_SECONDS = 1
    class CommandTimeoutException < BaseException; end

    def block_until_outcome
      start_time = Time.now
      until finished?
        if (Time.now - start_time) >= COMMAND_OUTCOME_TIMEOUT_SECONDS
          raise CommandTimeoutException.new("Command took more than #{COMMAND_OUTCOME_TIMEOUT_SECONDS} seconds to fully complete!")
        end
        Kernel.sleep POLL_INTERVAL_SECONDS
        refresh
      end
      return success
    end
  end
end
