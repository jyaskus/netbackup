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
        # p1
        '10.24.0.64/26'    => 'sa0319nbu01-2409',
        '10.24.8.0/23'     => 'sa0319nbu01-2411',
        '10.24.192.0/26'   => 'sa0319nbu01-2551',
        '10.24.192.64/26'  => 'sa0319nbu01-2552',
        '10.24.192.128/26' => 'sa0319nbu01-2553',
        '10.24.192.192/26' => 'sa0319nbu01-2554',
        '10.24.193.0/26'   => 'sa0319nbu01-2555',
        '10.24.193.64/26'  => 'sa0319nbu01-2556',
        '10.24.193.128/26' => 'sa0319nbu01-2557',
        '10.24.193.192/27' => 'sa0319nbu01-2558',
        '10.24.193.224/27' => 'sa0319nbu01-2559',
        '10.24.194.0/27'   => 'sa0319nbu01-2560',
        '10.24.194.32/27'  => 'sa0319nbu01-2561',
        '10.24.194.64/27'  => 'sa0319nbu01-2562',
        '10.24.194.96/27'  => 'sa0319nbu01-2563',
        '10.24.194.128/27' => 'sa0319nbu01-2564',
        '10.24.196.0/23'   => 'sa0319nbu01-2565',
        '10.24.198.0/23'   => 'sa0319nbu01-2566',
        '10.24.194.176/28' => 'sa0319nbu01-2568',
        # 319
        '10.16.34.0/23'    => 'sa0319nbu03-0522',
        '10.16.64.0/23'    => 'sa0319nbu03-0620',
        '10.16.66.0/23'    => 'sa0319nbu03-0622',
        '10.16.57.0/25'    => 'sa0319nbu03-0642',
        '10.16.58.0/27'    => 'sa0319nbu03-0644',
        # yp37 (non-PCI)
        '10.16.32.0/23'    => 'y0319p37-v520',
        '10.16.37.32/28'   => 'y0319p37-v528',
        '10.16.37.48/28'   => 'y0319p37-v529',
        '10.16.45.48/28'   => 'y0319p37-v585',
        '10.16.58.64/28'   => 'y0319p37-v646',
        '10.16.58.80/28'   => 'y0319p37-v647',
        '10.16.69.0/27'    => 'y0319p37-v626',
        '10.16.69.32/28'   => 'y0319p37-v627',
        '10.16.69.64/27'   => 'y0319p37-v628',
        '10.16.78.0/23'    => 'y0319p37-v685',
        '10.16.246.128/25' => 'y0319p37-v797',
        # yp86 (PCI)
        '10.1.89.0/24'      => 'y0319p86-v925',
        '10.16.40.0/23'     => 'y0319p86-v560',
        '10.16.42.0/23'     => 'y0319p86-v562',
        '10.16.45.0/28'     => 'y0319p86-v566',
        '10.16.45.96/28'    => 'y0319p86-v571',
        '10.16.45.112/28'   => 'y0319p86-v572',
        '10.16.45.128/27'   => 'y0319p86-v573',
        '10.16.45.160/28'   => 'y0319p86-v574',
        '10.16.45.192/27'   => 'y0319p86-v575',
        '10.16.45.176/28'   => 'y0319p86-v576',
        '10.16.72.0/23'     => 'y0319p86-v660',
        '10.16.74.0/23'     => 'y0319p86-v662',
        '10.16.76.0/25'     => 'y0319p86-v664',
        '10.16.77.0/26'     => 'y0319p86-v666',
        '10.16.77.128/28'   => 'y0319p86-v669',
        '10.16.77.144/28'   => 'y0319p86-v670',
        '10.16.78.0/23'     => 'y0319p86-v685',
        '10.16.212.0/25'    => 'y0319p86-v942',
        '10.16.212.128/25'  => 'y0319p86-v943',
        '10.16.213.128/25'  => 'y0319p86-v945',
        '10.16.247.128/25'  => 'y0319p86-v799',
        '161.181.52.128/27' => 'y0319p86-v830',
        '161.181.243.0/25'  => 'y0319p86-v795'
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
      when 'x0319p09'
        servers_legacy_nonpci
      when 'y0319p85'
        servers_legacy_pci
      when 'sa0319nbu01'
        servers_p1
      when 'sa0319nbu02'
        servers_319
      when 'sa0864nbu01'
        servers_864
      when 'sa0606nbu01'
        servers_606
      end
    end

    def servers_legacy_pci
      %w(y0319p85 y0319p86 a0319p279)
    end

    def servers_319
      %w(sa0319nbu02 sa0319nbu03 sa0319nbu02.nordstrom.net sa0319nbu03.nordstrom.net)
    end

    def servers_864
      %w(sa0864nbu01 sa0864nbu01.nordstrom.net)
    end

    def servers_p1
      %w(sa0319nbu01 sa0319nbu01.nordstrom.net)
    end

    def servers_legacy_nonpci
      %w(x0319p09 y0319p37 y0319p286 a0319p281)
    end

    def servers_606
      %w(sa0606nbu01 sa0606nbu01.nordstrom.net)
    end
  end
end
