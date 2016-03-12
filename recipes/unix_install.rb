# Cookbook Name:: NetBackup
# Recipe:: unix_install
# Author: Jeff Yaskus
#
# GOAL: Wrapper for installing the appropriate client software
logheader = '--- NetBackup::Unix::Install --- '
Chef::Log.info(logheader)

# include the helper functions
extend NetBackup::Helpers

# local variable for the platform family
pfamily = node['platform_family']

if tagged?('netbackup_legacy')
  Chef::Log.info(logheader + " version found = #{installed_version} expected base= #{node['netbackup'][pfamily]['client_base_ver']} expected patch=#{node['netbackup'][pfamily]['client_patch_ver']}")
else
  Chef::Log.info(logheader + " version found = #{installed_version} expected version= #{node['netbackup'][pfamily]['client_appliance_ver']}")
end

# debug - display tags
# Chef::Log.info " --- install mode = #{install_mode(tagged?('netbackup_legacy'), tagged?('netbackup_pci'))} ---"

case install_mode(tagged?('netbackup_legacy'), tagged?('netbackup_pci'))
when :appliance
  if check_disk_space(node['netbackup'][pfamily]['client_appliance_tar_kb'])
    include_recipe "#{cookbook_name}::unix_install_appliance"
  else
    Chef::Log.info(logheader + ' WARNING - Not enough free space to install NetBackup client')
  end
when :install
  if check_disk_space(node['netbackup'][pfamily]['client_base_tar_kb'])
    include_recipe "#{cookbook_name}::unix_install_base"
    include_recipe "#{cookbook_name}::unix_install_patch"
  else
    Chef::Log.info(logheader + 'WARNING - Not enough free space to install NetBackup client')
  end
when :patch
  if check_disk_space(node['netbackup'][pfamily]['client_patch_tar_kb'])
    include_recipe "#{cookbook_name}::unix_install_patch"
  else
    Chef::Log.info(logheader + 'WARNING - Not enough free space to install NetBackup client ***')
  end
when :none
  # nothing to do here, software is installed
end
