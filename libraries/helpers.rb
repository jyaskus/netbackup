# Supports NetBackup cookbook
module NetBackup
  # helper functions for NetBackup
  module Helpers

    def var_disk_space
      case node['platform_family']
      when 'solaris2'
        # solaris doesnt support POSIX
        cmd = Mixlib::ShellOut.new('df -k /var | tail -1 | awk \'{print $4}\' ')
        cmd.run_command
        cmd.stdout.to_i
      else
        # uses posix output to deal with varying linux output styles
        cmd = Mixlib::ShellOut.new('df -k /var | tail -1 | awk \'{print $4}\' ')
        cmd.run_command
        cmd.stdout.to_i
      end # case
    end

    def usr_disk_space
      case node['platform_family']
      when 'solaris2'
        # solaris doesnt support POSIX
        cmd = Mixlib::ShellOut.new('df -k /usr | tail -1 | awk \'{print $4}\' ')
        cmd.run_command
        cmd.stdout.to_i
      else
        # uses posix output to deal with varying linux output styles
        cmd = Mixlib::ShellOut.new('df -P -k /usr | tail -1 | awk \'{print $4}\' ')
        cmd.run_command
        cmd.stdout.to_i
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
          servers_environment_legacy_pci
        else
          servers_environment_legacy_nonpci
        end
      else
        if pci 
          servers_environment_pci
        else
          servers_environment_nonpci
        end
      end
    end

    ## LINUX
    def get_server_policy(legacy, servername)
      if legacy
          return 'LINUX_Servers'
      else
          return 'LINUX_OS'
      end
    end

    def get_app_policy(legacy, servername)
      # u01 is the default unix app data volume #
      if legacy
          return 'APPL_Data'
      else
          return 'LINUX_APP'
      end
    end

    def get_db_policy(legacy, servername)
      if legacy
          return 'APPL_Database'
      else
          return 'LINUX_APP_DB'
      end
   end


    def netbackup_env_servers(master_server)
      case master_server
      when 'master1'
        servers_environment_legacy_nonpci
      when 'master2'
        servers_environment_legacy_pci
      when 'master3'
        servers_environment_nonpci
      when 'master4'
        servers_environment_pci
      end
    end

    def servers_environment_legacy_nonpci
      %w(master1 media1_1 media1_2)
    end

    def servers_environment_legacy_pci
      %w(master2 media2_1 media2_2)
    end

    def servers_environment_nonpci
      %w(master3 media3_1 media3_2)
    end

    def servers_environment_pci
      %w(master4 media4_1 media4_2)
    end

  end
end
