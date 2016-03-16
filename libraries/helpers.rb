# Supports NetBackup cookbook
module NetBackup
  # helper functions for NetBackup
  module Helpers
    require 'ipaddr'
    require 'socket'

    # converts netmask to CIDR notation
    def mask_to_ciddr(mask)
      '/' + mask.split('.').map { |e| e.to_i.to_s(2).rjust(8, '0') }.join.count('1').to_s
    end

    def set_ip_netmask
      node_ip = node['ipaddress']
      node_interface = node['network']['default_interface']
      node.default['netmask'] = node['network']['interfaces'][node_interface]['addresses'][node_ip]['netmask']
    end

    def lookup_vlan(your_ip, your_netmask)
      # exit if ipaddress is nil or not set
      if your_ip.nil? || !node.attribute?(:ipaddress)
        Chef::Log.info('WARNING -- node ipaddress is not set')
        return nil
      end

      # static hash table of subnets and
      # associated DNS entry for the tagged vlan
      # that are configured on the netbackup servers
      tagged_vlans = {
        # environment 1
        '10.16.32.0/23'    => 'media1_1-v032',
        '10.16.64.0/25'    => 'media1_1-v064',
        # environment 2
        '10.16.32.0/25'  => 'media2_1-v032',
        '10.16.64.0/25'  => 'media2_1-v064'
      }
      # make sure it returns nil if not found
      tagged_vlans.default = nil

      # converts subnet to CIDR mask format for hash lookup
      my_network = IPAddr.new("#{your_ip}/#{your_netmask}").to_s
      my_cidr = mask_to_ciddr(your_netmask)
      my_cidr_mask = "#{my_network}#{my_cidr}"

      # doing a HASH table lookup
      if tagged_vlans.key?(my_cidr_mask)
        return tagged_vlans[my_cidr_mask]
      else
        return nil
      end
    end

    def var_disk_space
      case node['platform_family']
      when 'rhel'
        # uses posix output to deal with varying linux output styles
        cmd = Mixlib::ShellOut.new('df -P -k /var | tail -1 | awk \'{print $4}\' ')
        cmd.run_command
        cmd.stdout.to_i
      when 'solaris2'
        # solaris doesnt support POSIX
        cmd = Mixlib::ShellOut.new('df -k /var | tail -1 | awk \'{print $4}\' ')
        cmd.run_command
        cmd.stdout.to_i
      else
        return 0 # to catch any unknown UNIX OSes
      end # case
    end

    def usr_disk_space
      case node['platform_family']
      when 'rhel'
        # uses posix output to deal with varying linux output styles
        cmd = Mixlib::ShellOut.new('df -P -k /usr | tail -1 | awk \'{print $4}\' ')
        cmd.run_command
        cmd.stdout.to_i
      when 'solaris2'
        # solaris doesnt support POSIX
        cmd = Mixlib::ShellOut.new('df -k /usr | tail -1 | awk \'{print $4}\' ')
        cmd.run_command
        cmd.stdout.to_i
      else
        return 0 # to catch any unknown UNIX OSes
      end # case
    end

    def check_disk_space(space_needed_kb)
      var_disk_space > (2 * space_needed_kb.to_i) && usr_disk_space > space_needed_kb.to_i
    end

    def installed_version
      # checking for existing software version info
      if ::File.exist?('/usr/openv/netbackup/bin/version')
        # the file should only have a single line in it
        file = File.open('/usr/openv/netbackup/bin/version')
        contents = file.read
        file.close

        data = contents.split(' ')
        return data[1]
      end
      nil
    end

    def existing_master
      if ::File.exist?('/usr/openv/netbackup/bp.conf')
        # parse the existing bp.conf
        File.open('/usr/openv/netbackup/bp.conf', 'r') do |f|
          f.each_line do |line|
            # do stuff here
            if line.include? 'SERVER'
              server = line[9..-2]
              return server
            end
          end
        end
        file.close
        return 'notfound'
      end
      nil
    end

    def install_mode(legacy, _pci)
      # local variable to use when looking up attributes
      pfamily = node['platform_family']
      # default to appliance install
      # determine mode based on tags
      if !legacy
        if installed_version == node['netbackup'][pfamily]['client_appliance_ver']
          return :none
        else
          return :appliance
        end
      else
        case installed_version
        when node['netbackup'][pfamily]['client_base_ver'] # '7.5'
          # just apply the patch
          return :patch
        when node['netbackup'][pfamily]['client_patch_ver'] # '7.5.0.7'
          # nothing to install
          return :none
        else
          # install the base client and patch it
          return :install
        end
      end
    end

    def netbackup_server_list(legacy, pci)
      hostname = node['hostname']
      if legacy
        if pci
          servers_legacy_pci
        else
          servers_legacy_nonpci
        end
      else
        if pci # P1
          servers_p1
        elsif hostname.match(/0864/)
          servers_864
        elsif hostname.match(/0870/)
          servers_864
        else
          servers_319
        end
      end
    end

    ## LINUX
    def linux_server_policy(legacy, servername)
      if legacy
        if servername.match(/t/)
          return 'LINUX_Test_Servers_Via_Network'
        else
          return 'LINUX_Servers_Via_Network'
        end
      else
        # non-legacy servers
        if servername.match(/t/)
          return 'LINUX_Test_OS'
        else
          return 'LINUX_OS'
        end
      end
    end

    def linux_app_policy(legacy, servername)
      # u01 is the default unix app data volume #
      if legacy
        if servername.match(/t/)
          return 'APPL_Test_Ntwk_u01'
        else
          return 'APPL_Ntwk_u01'
        end
      else
        # non-legacy servers
        if servername.match(/t/)
          return 'LINUX_Test_APP_U01'
        else
          return 'LINUX_APP_U01'
        end
      end
    end

    def linux_db_policy(legacy, servername)
      if legacy
        if servername.match(/t/)
          return 'APPL_Ntwk_Test_Oracle'
        else
          return 'APPL_Ntwk_Oracle'
        end
      else
        # non-legacy servers
        if servername.match(/t/)
          return 'LINUX_Test_APP_DB'
        else
          return 'LINUX_APP_DB'
        end
      end
    end

    ## Solaris
    def solaris_server_policy(legacy, servername)
      if legacy
        if servername.match(/t/)
          return 'SUN_Test_Servers_Via_Network'
        else
          return 'SUN_Servers_Via_Network'
        end
      else
        # non-legacy servers
        if servername.match(/t/)
          return 'SOLARIS_Test_OS'
        else
          return 'SOLARIS_OS'
        end
      end
    end

    def solaris_app_policy(legacy, servername)
      # u01 is the default unix app data volume #
      if legacy
        if servername.match(/t/)
          return 'APPL_Test_Ntwk_u01'
        else
          return 'APPL_Ntwk_u01'
        end
      else
        # non-legacy servers
        if servername.match(/t/)
          return 'SOLARIS_Test_APP_U01'
        else
          return 'SOLARIS_APP_U01'
        end
      end
    end

    def solaris_db_policy(legacy, servername)
      if legacy
        if servername.match(/t/)
          return 'APPL_Ntwk_Test_Oracle'
        else
          return 'APPL_Ntwk_Oracle'
        end
      else
        # non-legacy servers
        if servername.match(/t/)
          return 'SOLARIS_Test_APP_DB'
        else
          return 'SOLARIS_APP_DB'
        end
      end
    end

    def get_server_policy(legacy, servername)
      case node['platform_family']
      when 'rhel'
        return linux_server_policy(legacy, servername)
      when 'solaris2'
        return solaris_server_policy(legacy, servername)
      else
        return nil
      end
    end

    def get_app_policy(legacy, servername)
      case node['platform_family']
      when 'rhel'
        return linux_app_policy(legacy, servername)
      when 'solaris2'
        return solaris_app_policy(legacy, servername)
      else
        return nil
      end
    end

    def get_db_policy(legacy, servername)
      case node['platform_family']
      when 'rhel'
        return linux_db_policy(legacy, servername)
      when 'solaris2'
        return solaris_db_policy(legacy, servername)
      else
        return nil
      end
    end

    def netbackup_env_servers(master_server)
      case master_server
      when 'master1'
        servers_environment_a
      when 'master2'
        servers_environment_b
      when 'master3'
        servers_environment_c
      when 'master4'
        servers_environment_d
      end
    end

    def servers_environment_a
      %w(master1 media1_1 media1_2)
    end

    def servers_environment_b
      %w(master2 media2_1 media2_2)
    end

    def servers_environment_c
      %w(master3 media3_1 media3_2)
    end

    def servers_environment_d
      %w(master4 media4_1 media4_2)
    end

  end
end
