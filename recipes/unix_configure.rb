# Cookbook Name:: NetBackup
# Recipe:: unix_configure
# Author: Jeff Yaskus
#
# GOAL: manage clients config settings for NetBackup (UNIX)
logheader = '--- NetBackup::Unix::Configure --- '
Chef::Log.info(logheader)

extend NetBackup::Helpers

# localize the chef tags as variables to pass
tagged_legacy = tagged?('netbackup_legacy')
tagged_pci = tagged?('netbackup_pci')

# local variable for the platform family
pfamily = node['platform_family']

# create a server list in advance, in case we need to add additional entries to it
server_list = netbackup_server_list(tagged_legacy, tagged_pci)
master_server = server_list[0]

if File.file? '/usr/openv/netbackup/bp.conf'

 # check if the user added CUSTOM anywhere in the bp.con
 # this allows local over-rides if needed
 if File.readlines('/usr/openv/netbackup/bp.conf').grep(/CUSTOM/).any?
   Chef::Log.info(logheader + 'CUSTOM entry found in bp.conf (no changes will be made)')
   return # exit from this recipe
 end

 # compare the existing master and default
 #
 if master_server != existing_master
   if tagged_legacy

     if tagged_pci
       master_server = 'master2'
     else
       master_server = 'master1'
       # default for Legacy non-pci
     end

   else
    # non legacy

    if tagged?('netbackup_pci') 
      master_server = 'master4'
    else
      master_server = 'master3'
    end

   end # if tagged
  end # if differs

end # if file exists

# update server list in case MASTER was changed
server_list = netbackup_env_servers(master_server)

# --- CHECK VLANs --- #
# IF it is found to exist on a tagged VLAN -
# then we need to add it as the first SERVER entry

# determine the netmask
#set_ip_netmask

# set local variables for default network
#ip_netmask = node['netmask']
#ip_address = node['ipaddress']

# check if it matches any known tagged VLAN subnets
# use the hash table lookup
#vlantag = lookup_vlan(ip_address, ip_netmask)

#unless vlantag.nil?
#  Chef::Log.info(logheader + "This clients address #{ip_address} is on a known tagged VLAN (#{vlantag})")

#  # adds the tagged vlan as first entry in server list
#  server_list.unshift(vlantag)
#  # else
#  #  Chef::Log.info(logheader + "--- NetBackup --- No tagged VLANs found for this IP address (#{ip_address})")
#end

# if we got this far, assumes we passed all of the logic checks

# create the required log directories
%w(logs logs/bpcd logs/bprd).each do |path|
  directory "#{node['netbackup'][pfamily]['target_dir']}/#{path}" do
    owner 'root'
    group 'root'
    mode '0755'
    not_if { ::Dir.exist?("#{node['netbackup'][pfamily]['target_dir']}/#{path}") }
  end
end # done creating log directories

# creates the NetBackup tuneable(s)
template "#{node['netbackup'][pfamily]['target_dir']}/#{node['netbackup'][pfamily]['net_buffer_file']}" do
  source 'net_buffer.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables net_buffer_size: node['netbackup'][pfamily]['net_buffer_size_bytes']
  not_if { ::File.exist?("#{node['netbackup'][pfamily]['target_dir']}/#{node['netbackup'][pfamily]['net_buffer_file']}") }
end

# create a new bp.conf file
template "#{node['netbackup'][pfamily]['target_dir']}/#{node['netbackup'][pfamily]['config_file']}" do
  extend NetBackup::Helpers
  source 'bpconf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables servers: server_list
end
