module ClouderaManager
  class BulkCommand < Array
    include CommandActions

    def initialize(*commands)
      commands.each do |attrs|
        self << Command.new(attrs)
      end
    end

    def success
      size > 0 && all? { |command| command.success }
    end

    def finished?
      size == 0 || all? { |command| command.finished? }
    end

    def refresh
      each { |command| command.refresh }
    end

    def success_ratio
      finished = select { |command| command.finished? }
      if finished.size > 0
        successes, fails = finished.partition { |command| command.success }.map(&:size)
        successes / (successes + fails).to_f
      else
        0
      end
    end
  end
end
