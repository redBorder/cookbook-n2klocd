#
# Cookbook Name:: n2klocd
# Recipe:: default
#
# redborder
#
#

n2klocd_config "config" do
  name node["hostname"]
  action :add
end
