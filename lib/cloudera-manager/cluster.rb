module ClouderaManager
  class Cluster < BaseResource
    has_many :services
    has_many :commands
    primary_key :name
  end
end
