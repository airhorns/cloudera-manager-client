module ClouderaManager
  class Role < BaseResource

    belongs_to :service
    belongs_to :host
    collection_path "clusters/:cluster_id/services/:service_id/roles"
    primary_key :name

    after_find do |role|
      role.service_id = role.serviceRef[:serviceName]
      role.cluster_id = role.serviceRef[:clusterName]
    end
  end
end
