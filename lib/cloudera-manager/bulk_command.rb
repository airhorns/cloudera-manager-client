module ClouderaManager
  class BulkCommand < Array
    def initialize(*commands)
      commands.each do |attrs|
        self << Command.new(attrs)
      end
    end

    def success
      size > 0 && all? {|command| command.success }
    end
  end
end
