# Cookbook Name:: n2klocd
#
# Provider:: config
#
action :add do
  begin
    config_dir = new_resource.config_dir
    memory = new_resource.memory
    logdir = new_resource.logdir
    user = new_resource.user
    group = new_resource.group
    mse_nodes = new_resource.mse_nodes
    meraki_nodes = new_resource.meraki_nodes
    port_meraki = new_resource.port_meraki
    port_HTTP = new_resource.port_HTTP
    port_n2klocd = new_resource.port_n2klocd
    n2klocd_managers = new_resource.n2klocd_managers

    # install package
    dnf_package "redborder-n2klocd" do
      action :upgrade
      flush_cache [ :before ]
    end

    user user do
      action :create
    end

    directory logdir do
      owner user
      group group
      mode 0770
      action :create
    end

    directory config_dir do #/etc/n2klocd
      owner user
      group group
      mode 0755
      action :create
    end


    template "/etc/n2klocd/config.json" do
      source "config.json.erb"
      cookbook "n2klocd"
      owner "root"
      group "root"
      mode 0644
      retries 2
      #variables(:kafka_managers => managers_per_service["kafka"], :n2klocd_managers => managers_per_service["n2klocd"], :mse_nodes => mse_nodes, :meraki_nodes => meraki_nodes, :memory => memory_services["n2klocd"])
      variables(:port_meraki => port_meraki, :port_HTTP => port_HTTP, :port_n2klocd => port_n2klocd, :n2klocd_managers => n2klocd_managers,:mse_nodes => mse_nodes, :meraki_nodes => meraki_nodes, :memory => memory)
      notifies :restart, "service[n2klocd]", :delayed
    end

    #end of templates

    service "n2klocd" do
      service_name "n2klocd"
      ignore_failure true
      supports :status => true, :reload => true, :restart => true
      action [:enable, :start]
    end

    Chef::Log.info("cookbook n2klocd has been processed.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service "n2klocd" do
      service_name "n2klocd"
      supports :status => true, :restart => true, :start => true, :enable => true, :disable => true
      action [:disable, :stop]
    end
    Chef::Log.info("cookbook n2klocd has been processed.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


action :register do #Usually used to register in consul
  begin
    if !node["n2klocd"]["registered"]
      query = {}
      query["ID"] = "n2klocd-#{node["hostname"]}"
      query["Name"] = "n2klocd"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 2057
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["n2klocd"]["registered"] = true
    end
    Chef::Log.info("n2klocd service has been registered in consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do #Usually used to deregister from consul
  begin
    if node["n2klocd"]["registered"]
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/n2klocd-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["n2klocd"]["registered"] = false
    end
    Chef::Log.info("n2klocd service has been deregistered from consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end
