# Cookbook Name:: NetBackup
# Recipe:: solaris
# Author: Jeff Yaskus
#
# GOAL: Wrapper to manage software install and configuration (solaris)
Chef::Log.info('--- NetBackup::Solaris --- ')
extend NetBackup::Helpers

# dont modify MEDIA or MASTER servers
return if ::File.directory?('/usr/openv/db')

# install and patch the client
include_recipe 'netbackup::unix_install'

# configure the client
# But check to make sure it was installed or update properly first
if install_mode(tagged?('netbackup_legacy'), tagged?('netbackup_pci')) == :none
  include_recipe 'netbackup::unix_configure'

  # configure the exclude list for the client
  include_recipe 'netbackup::unix_excludes'
end
