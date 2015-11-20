module ClouderaManager
  class Cluster < BaseResource
    has_many :services
  end
end
