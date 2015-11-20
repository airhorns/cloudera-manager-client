require 'test_helper'

class ClouderaManager::HostTest < RemoteTest
  def test_getting_the_hosts_retrieves_a_page_of_hosts
    @hosts = ClouderaManager::Host.all.to_a
    assert_equal 88, @hosts.size
  end

  def test_getting_a_host_retrieves_a_host
    @host = ClouderaManager::Host.find('4f8ebfcb-20c9-47f1-bd0e-cd3f1d8c891e')
    assert_equal 'hadoop-util1.chi.shopify.com', @host.hostname
  end

  def test_retrieving_hosts_by_hostname
    @host = ClouderaManager::Host.find_by_hostname('hadoop-util1.chi.shopify.com')
    assert_equal 'hadoop-util1.chi.shopify.com', @host.hostname
    assert_equal '4f8ebfcb-20c9-47f1-bd0e-cd3f1d8c891e', @host.id

    assert_raises(ClouderaManager::Host::HostNotFoundException) do
      ClouderaManager::Host.find_by_hostname('expensive-other-database.shopify.com')
    end
  end

  def test_hadoopy_for_hosts_is_true_if_they_are_found_in_cloudera_manager
    assert ClouderaManager::Host.hadoopy?('hadoop-util1.chi.shopify.com')
  end

  def test_hadoopy_for_hosts_is_true_if_they_are_not_found_in_cloudera_manager
    assert !ClouderaManager::Host.hadoopy?('expensive-other-database.shopify.com')
  end

  def test_putting_a_host_into_maintenance_mode_success
    @host = ClouderaManager::Host.find('4f8ebfcb-20c9-47f1-bd0e-cd3f1d8c891e')
    assert !@host.maintenanceMode

    @command = @host.enter_maintenance_mode!
    assert @host.maintenanceMode

    assert @command.success
    assert !@command.active
  end

  def test_putting_a_host_into_maintenance_mode_failure
    @host = ClouderaManager::Host.find('4f8ebfcb-20c9-47f1-bd0e-cd3f1d8c891e')
    assert !@host.maintenanceMode

    @command = @host.enter_maintenance_mode!
    assert !@host.maintenanceMode

    assert !@command.success
    assert_equal "Thing failed", @command.resultMessage
  end

  def test_exiting_a_host_from_maintenance_mode_success
    @host = ClouderaManager::Host.find('4f8ebfcb-20c9-47f1-bd0e-cd3f1d8c891e')
    assert !@host.maintenanceMode

    @host.enter_maintenance_mode!
    assert @host.maintenanceMode

    @command = @host.exit_maintenance_mode!
    assert !@host.maintenanceMode

    assert @command.success
    assert !@command.active
  end

  def test_exiting_a_host_from_maintenance_mode_failure
    @host = ClouderaManager::Host.find('4f8ebfcb-20c9-47f1-bd0e-cd3f1d8c891e')
    assert !@host.maintenanceMode

    @host.enter_maintenance_mode!
    assert @host.maintenanceMode

    @command = @host.exit_maintenance_mode!
    assert @host.maintenanceMode

    assert !@command.success
    assert_equal "Thing failed", @command.resultMessage
  end
end
