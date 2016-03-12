# Cookbook Name:: NetBackup
# Recipe:: unix_excludes
# Author: Jeff Yaskus
#
# GOAL: Manage client side exclude lists (UNIX)
Chef::Log.info('--- NetBackup::Unix::Excludes  ---')
extend NetBackup::Helpers

# localize the chef tags as variables to pass
tagged_legacy = tagged?('netbackup_legacy')

# local variable for the platform family
pfamily = node['platform_family']

# STEP 1
# Build the standard OS backup exclude list
policy_name = get_server_policy(tagged_legacy, node['hostname'])
filename = "#{node['netbackup'][pfamily]['target_dir']}/exclude_list.#{policy_name}"

# create a response file for the install process
template filename do
  extend NetBackup::Helpers
  source 'exclude_list_OS.erb'
  owner 'root'
  group 'root'
  mode '0644'
  not_if { ::File.exist?(filename) }
end

# STEP 2
# Build the standard u01 volume backup exclude list
policy_name = get_app_policy(tagged_legacy, node['hostname'])
filename = "#{node['netbackup'][pfamily]['target_dir']}/exclude_list.#{policy_name}"

# create a response file for the install process
template filename do
  extend NetBackup::Helpers
  source 'exclude_list_u01.erb'
  owner 'root'
  group 'root'
  mode '0644'
  not_if { ::File.exist?(filename) }
end

# STEP 3
# Build the standard OS backup exclude list
policy_name = get_db_policy(tagged_legacy, node['hostname'])
filename = "#{node['netbackup'][pfamily]['target_dir']}/exclude_list.#{policy_name}"

# create a response file for the install process
template filename do
  extend NetBackup::Helpers
  source 'exclude_list_db.erb'
  owner 'root'
  group 'root'
  mode '0644'
  not_if { ::File.exist?(filename) }
end
