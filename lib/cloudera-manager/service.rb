module ClouderaManager
  class Service < BaseResource

    belongs_to :cluster
    has_many :roles
    primary_key :name
    collection_path "clusters/:cluster_id/services"
    after_find { |s| s.cluster_id = s.clusterRef[:clusterName] }

    RESTART_ORDER = {
      "YARN" => ["JOBHISTORY", "NODEMANAGER", "RESOURCEMANAGER"],
      "HDFS" => ["HTTPFS", "FAILOVERCONTROLLER", "NFSGATEWAY", "DATANODE", "JOURNALNODE", "SECONDARYNAMENODE", "NAMENODE"],
      "IMPALA" => ["IMPALAD", "STATESTORE", "CATALOGSERVER", "LLAMA"]
    }

    def enterprise_rolling_restart!
      remote_command!("/commands/rollingRestart")
    end

    def rolling_restart!(bulk_batch_size)
      ordered_role_types = RESTART_ORDER[self.type] || self.role_types
      ordered_role_types.each_with_object(ClouderaManager::BulkCommand.new) do |role_type, all_commands|
        logger.info "Starting rolling restart of #{self.name} - #{role_type}"
        all_commands.concat RestartStrategy.determine(self, role_type, bulk_batch_size).run
        logger.info "Rolling restart of #{self.name} - #{role_type} finished!"
      end
    end

    def restart_role_instances!(role_instances)
      remote_command!("/roleCommands/restart", items: role_instances)
    end

    def role_types
      remote_property("/roleTypes")
    end

    def restartable_role_names_for_type(role_type)
      roles.to_a.select { |role| role.type == role_type && role.roleState != "NA" }.map(&:name)
    end
  end
end
