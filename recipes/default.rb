# Cookbook Name:: NetBackup
# Recipe:: default
# Author: Jeff Yaskus

# enable to display INFO messages
# by default these should not display
Chef::Log.level = :info

untag('netbackup_legacy')
untag('netbackup_pci')

# a "safe word" to prevent netbackup from installing software
return if tagged?('netbackup_ignore')

case node['platform_family']
when 'windows'
  include_recipe 'netbackup::windows'
when 'rhel'
  include_recipe 'netbackup::redhat'
when 'debian'
  include_recipe 'netbackup::debian'
when 'solaris2'
  include_recipe 'netbackup::solaris'
else
  Chef::Log.info "NetBackup cookbook does not support your platform #{node['platform_family']}  (yet!) "
end
