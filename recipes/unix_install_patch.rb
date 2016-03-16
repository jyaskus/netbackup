# Cookbook Name:: NetBackup
# Recipe:: unix_install_patch
# Author: Jeff Yaskus
#
# GOAL: Install client patch (UNIX)
Chef::Log.info('--- NetBackup::Unix::Install::Patch --- ')
extend NetBackup::Helpers

# local variable for the platform family
pfamily = node['platform_family']

# create a response file for the patch process
template "#{Chef::Config['file_cache_path']}/#{node['netbackup'][pfamily]['client_patch_response']}" do
  source 'response_patch.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables package_to_install: node['netbackup'][pfamily]['client_patch_pkg']
  # action: create
end

# grab remote file
remote_file "#{Chef::Config['file_cache_path']}/#{node['netbackup'][pfamily]['client_patch_tar']}" do
  source "#{node['netbackup'][pfamily]['client_patch_url']}/#{node['netbackup'][pfamily]['client_patch_tar']}"
#  checksum node['netbackup'][pfamily]['client_patch_sum']
  owner 'root'
  group 'root'
  mode '00755'
end

# patch NetBackup client
bash 'patching_netbackup' do
  cwd Chef::Config['file_cache_path']
  code <<-EOF
  tar xvpf #{node['netbackup'][pfamily]['client_patch_tar']}
  rm #{node['netbackup'][pfamily]['client_patch_tar']}

  cd #{node['netbackup'][pfamily]['client_patch_dir']}
  sh ./NB_update.install < ../#{node['netbackup'][pfamily]['client_patch_response']}

  cd ..
  if [ -d #{node['netbackup'][pfamily]['client_patch_dir']} ]; then
     rm -rf #{node['netbackup'][pfamily]['client_patch_dir']}
  fi

  EOF
end
