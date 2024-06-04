# Cookbook:: n2klocd
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :config_dir, kind_of: String, default: '/etc/n2klocd'
attribute :name, kind_of: String, default: 'localhost'
attribute :ip, kind_of: String, default: '127.0.0.1'
attribute :mse_nodes, kind_of: Array, default: []
attribute :meraki_nodes, kind_of: Array, default: []
attribute :port_meraki, kind_of: Integer, default: 2058
attribute :port_HTTP, kind_of: Integer, default: 2056
attribute :port_n2klocd, kind_of: Integer, default: 2057
attribute :n2klocd_managers, kind_of: Array, default: ['localhost']
attribute :logdir, kind_of: String, default: '/var/log/n2klocd'
attribute :user, kind_of: String, default: 'n2klocd'
attribute :group, kind_of: String, default: 'n2klocd'
attribute :memory, kind_of: Integer, default: 0
