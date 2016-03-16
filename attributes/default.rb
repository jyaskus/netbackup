# Cookbook Name:: NetBackup
# Recipe:: default
# Author: Jeff Yaskus
#
# predefines variables used during install process
# updated to match platform_family names
default['netbackup']['rhel'] = {
  net_buffer_size_bytes: '262144',
  net_buffer_file: 'NET_BUFFER_SZ',
  target_dir: '/usr/openv/netbackup',
  config_file: 'bp.conf',

  client_base_ver: '7.5',
  client_base_dir: 'NetBackup_7.5_CLIENTS',
  client_base_url: 'http://hostingsite.com/netbackup_client_redhat/7.5.0.7',
  client_base_tar: 'netbackup_client_redhat-7.5.0.7-base.tar',
  client_base_tar_kb: '700000',
  client_base_sum: 'e5723ccc9d4aefffbd52f24f39024bbed2ec4ed99292505cc6d1b1e0308c9253',
  client_base_response: 'response.install',

  client_patch_ver: '7.5.0.7',
  client_patch_dir: 'NB_update',
  client_patch_tar: 'netbackup_client_redhat-7.5.0.7-patch.tar',
  client_patch_tar_kb: '400000',
  client_patch_url: 'http://hostingsite.com/netbackup_client_redhat/7.5.0.7',
  client_patch_sum: '5e7dd2377618d10bab3d5cb0a193c821109109b2f432921b90823bd8a9506979',
  client_patch_pkg: 'NB_CLT_7.5.0.7',
  client_patch_response: 'response.patch',

  client_appliance_ver: '7.6.1.1',
  client_appliance_dir: 'SYMCnbclient_Linux-RedHat2.6.18_7.6.1.1',
  client_appliance_tar: 'netbackup_client_redhat-7.6.1.1.tar',
  client_appliance_tar_kb: '500000',
  client_appliance_url: 'http://hostingsite.com/netbackup_client_redhat/7.6.1.1',
  client_appliance_sum: 'fc894a7072fec98b5a2c0a51d7d098b015709288eff59e6fa3debb1e42c2e879',
  client_appliance_pkg: 'NB_CLT_7.6.1.1',
  client_appliance_response: 'response.install'
}
default['netbackup']['solaris2'] = {
  net_buffer_size_bytes: '1048576',
  net_buffer_file: 'NET_BUFFER_SZ',
  target_dir: '/usr/openv/netbackup',
  config_file: 'bp.conf',

  client_base_ver: '7.5',
  client_base_dir: 'NetBackup_7.5_CLIENTS',
  client_base_url: 'http://hostingsite.com/netbackup_client_solaris/7.5',
  client_base_tar: 'netbackup_client_solaris-7.5.tar',
  client_base_tar_kb: '600000',
  client_base_sum: '4c38bb8811e1952a18838bcb378b70beb6019dfc66d4294f2ff39ee48c7130d4',
  client_base_response: 'response.install',

  client_patch_ver: '7.5.0.7',
  client_patch_dir: 'NB_CLT_7.5.0.7',
  client_patch_tar: 'netbackup_client_solaris-7.5.0.7.tar',
  client_patch_tar_kb: '1000000',
  client_patch_url: 'http://hostingsite.com/netbackup_client_solaris/7.5.0.7',
  client_patch_sum: 'c9657206ff36dacfb396f60e25ece1fc227892606aa6124259780dda2407602c',
  client_patch_pkg: 'NB_CLT_7.5.0.7',
  client_patch_response: 'response.patch',

  client_appliance_ver: '7.6.1.1',
  client_appliance_dir: 'netbackup_client_solaris_10_x86_v7611',
  client_appliance_tar: 'netbackup_client_solaris-7.6.1.1.tar',
  client_appliance_tar_kb: '900000',
  client_appliance_url: 'http://hostingsite.com/netbackup_client_solaris/7.6.1.1',
  client_appliance_sum: 'edeead17bc0d57103e4d05186feb78119e3b2ee9933990dd4df13f5ca8477556',
  client_appliance_pkg: 'NB_CLT_7.6.1.1',
  client_appliance_response: 'response.install'
}
