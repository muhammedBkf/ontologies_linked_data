require "test/unit"
require_relative "../../lib/ontologies_linked_data"

class TestLinkedDataConfig < MiniTest::Unit::TestCase

  def teardown
    Goo.class_variable_set("@@sparql_backends", {})
    LinkedData.instance_variable_set("@settings_run", false)
    load(File.expand_path("../../../config/config.rb", __FILE__))
  end

  def test_default_config
    Goo.class_variable_set("@@sparql_backends", {})
    LinkedData.instance_variable_set("@settings_run", false)
    LinkedData.config()
    assert_equal(LinkedData.settings.goo_host, 'localhost', msg="goo_host != localhost")
    assert_equal(Goo.sparql_data_client.nil?, false, msg='sparql_data_client is nil')
    assert_equal(Goo.sparql_update_client.nil?, false, msg='sparql_update_client is nil')
    assert_equal(Goo.sparql_query_client.nil?, false, msg='sparql_query_client is nil')
  end

  def test_custom_config
    test_port = 1111
    test_host = "test_host"

    # Override safety check
    LinkedData.instance_variable_set("@settings_run", false)

    # Re-configure
    LinkedData.config do |config, overide_connect_goo|
      # Prevent goo connection
      overide_connect_goo = true
      # Settings
      config.goo_port = test_port
      config.goo_host = test_host
    end

    assert_equal(LinkedData.settings.goo_host, test_host, msg="goo_host != test_host")
    assert_equal(LinkedData.settings.goo_port, test_port, msg="goo_port != test_port")
    assert_equal(Goo.sparql_data_client.nil?, false, msg='sparql_data_client is nil')
    assert_equal(Goo.sparql_update_client.nil?, false, msg='sparql_update_client is nil')
    assert_equal(Goo.sparql_query_client.nil?, false, msg='sparql_query_client is nil')
  end

end
