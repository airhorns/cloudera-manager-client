module ClouderaManager
  class Command < BaseResource
    include CommandActions
    
    def finished?
      !active
    end
  end
end
