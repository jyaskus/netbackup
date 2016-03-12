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

# checks for LEGACY NETBACKUP (only)
if tagged_legacy

  # check for any entries with tagged vLAN entries such as: y031p37-v555
  # The naming standard changed outside legacy ... it now uses y0319p37-0555 (no v)
  if File.file? '/usr/openv/netbackup/bp.conf'

    if File.readlines('/usr/openv/netbackup/bp.conf').grep(/CUSTOM/).any?
      Chef::Log.info(logheader + 'CUSTOM entry found in bp.conf (no changes will be made)')
      return # exit from this recipe
    end

    # check for any entries with -NBu, used in legacy environment (only)
    if File.readlines('/usr/openv/netbackup/bp.conf').grep(/NBu/).any?
      Chef::Log.info(logheader + 'Warning: NBu overrides found! (existing bp.conf will be left in place)')
      return # exit from this recipe
    end

    # check if the MASTER passed to this recipe differs from the existing (first) SERVER = entry
    # before changing anything see what the existing file has defined for the master server

    # if the existing MASTER entry differs from the current default
    # use some logic to correctly update the clients
    if master_server != existing_master
      if !tagged_pci
        # default for Legacy
        master_server = 'x0319p09'
        Chef::Log.info(logheader + "Chef Tag found : using MASTER server #{master_server} ---")
      else
        # if it is tagged PCI, force it to use y0319p85
        master_server = 'y0319p85'
        Chef::Log.info(logheader + "Chef Tag found : using MASTER server #{master_server} ---")
      end
    end

  end # end of if (file exists)
  # done with checks for LEGACY servers
else
  # checks for non LEGACY servers
  # before changing anything see what the existing file has defined for the master server
  if ::File.exist?('/usr/openv/netbackup/bp.conf')

    if File.readlines('/usr/openv/netbackup/bp.conf').grep(/CUSTOM/).any?
      Chef::Log.info(logheader + 'CUSTOM entry found in bp.conf (no changes will be made) ---')
      return # exit from this recipe
    end

    # if the existing MASTER entry differs from the current default
    # leave it alone, unless we have a chef tag ... that over-rides any default
    if tagged?('netbackup_p1')
      master_server = 'sa0319nbu01'
    elsif tagged?('netbackup_pci') # makes assumption PCI and non-legacy ... means P1
      master_server = 'sa0319nbu01'
    elsif tagged?('netbackup_319')
      master_server = 'sa0319nbu02'
    elsif tagged?('netbackup_864')
      master_server = 'sa0864nbu01'
    elsif tagged?('netbackup_606')
      master_server = 'sa0606nbu01'
    end

    # existing MASTER matches the current default ?
  end
end # logic checks

# update server list in case MASTER was changed
server_list = netbackup_env_servers(master_server)

# --- CHECK VLANs --- #
# IF it is found to exist on a tagged VLAN -
# then we need to add it as the first SERVER entry

# determine the netmask
set_ip_netmask

# set local variables for default network
ip_netmask = node['netmask']
ip_address = node['ipaddress']

# check if it matches any known tagged VLAN subnets
# use the hash table lookup
vlantag = lookup_vlan(ip_address, ip_netmask)

unless vlantag.nil?
  Chef::Log.info(logheader + "This clients address #{ip_address} is on a known tagged VLAN (#{vlantag})")

  # adds the tagged vlan as first entry in server list
  server_list.unshift(vlantag)
  # else
  #  Chef::Log.info(logheader + "--- NetBackup --- No tagged VLANs found for this IP address (#{ip_address})")
end

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
