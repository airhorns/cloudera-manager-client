module ClouderaManager
  class Service < BaseResource

    belongs_to :cluster
    has_many :roles
    primary_key :name
    collection_path "clusters/:cluster_id/services"
    after_find { |s| s.cluster_id = s.clusterRef[:clusterName] }


    def role_types
      remote_property("/roleTypes")
    end
  end
end
