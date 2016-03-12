# Cookbook Name:: NetBackup
# Recipe:: unix_install_base
# Author: Jeff Yaskus
#
# GOAL: Install base client (UNIX)
Chef::Log.info('--- NetBackup::Unix::Install::Base ---')
extend NetBackup::Helpers

# localize the chef tags as variables to pass
tagged_legacy = tagged?('netbackup_legacy')
tagged_pci = tagged?('netbackup_pci')

# local variable for the platform family
pfamily = node['platform_family']

# create a server list in advance, in case we need to add additional entries to it
server_list = netbackup_server_list(tagged_legacy, tagged_pci)

# create a response file for the install process
template "#{Chef::Config['file_cache_path']}/#{node['netbackup'][pfamily]['client_base_response']}" do
  extend NetBackup::Helpers
  source 'response_install.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables master_server: server_list[0]
end

remote_filename = "#{node['netbackup'][pfamily]['client_base_url']}/#{node['netbackup'][pfamily]['client_base_tar']}"
local_filename = "#{Chef::Config['file_cache_path']}/#{node['netbackup'][pfamily]['client_base_tar']}"
Chef::Log.info(" source = #{remote_filename} local = #{local_filename}")

# grab remote file
remote_file local_filename do
  source remote_filename
  checksum node['netbackup'][pfamily]['client_base_sum']
  owner 'root'
  group 'root'
  mode '0755'
end

# Install NetBackup client
bash 'installing_netbackup_client' do
  cwd Chef::Config['file_cache_path']
  code <<-EOF
  tar xvpf #{node['netbackup'][pfamily]['client_base_tar']}
  rm #{node['netbackup'][pfamily]['client_base_tar']}

  cd #{node['netbackup'][pfamily]['client_base_dir']}
  ./install < #{Chef::Config['file_cache_path']}/#{node['netbackup'][pfamily]['client_base_response']}

  cd ..
  if [ -d #{node['netbackup'][pfamily]['client_base_dir']} ]; then
     rm -rf #{node['netbackup'][pfamily]['client_base_dir']}
  fi
  EOF
end
