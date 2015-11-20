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
    assert @command.message = "Thing failed"
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
    assert @command.message = "Thing failed"
  end
end
