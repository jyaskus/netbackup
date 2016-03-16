# Cookbook Name:: NetBackup
# Recipe:: default
# Author: Jeff Yaskus
#
# predefines variables used during install process
# updated to match platform_family names
default['netbackup']['debian'] = {
  net_buffer_size_bytes: '262144',
  net_buffer_file: 'NET_BUFFER_SZ',
  target_dir: '/usr/openv/netbackup',
  config_file: 'bp.conf',

  client_base_ver: '7.5',
  client_base_dir: 'NetBackup_7.5_CLIENTS',
  client_base_url: 'http://jyaskus.com.s3-website-us-west-2.amazonaws.com/files',
  client_base_tar: 'netbackup_client_linux-7.5-base.tar',
  client_base_tar_kb: '700000',
  client_base_sum: 'e5723ccc9d4aefffbd52f24f39024bbed2ec4ed99292505cc6d1b1e0308c9253',
  client_base_response: 'response.install',

  client_patch_ver: '7.5.0.7',
  client_patch_dir: 'NB_update',
  client_patch_tar: 'netbackup_client_linux-7.5.0.7-patch.tar',
  client_patch_tar_kb: '400000',
  client_patch_url: 'http://jyaskus.com.s3-website-us-west-2.amazonaws.com/files',
  client_patch_sum: '5e7dd2377618d10bab3d5cb0a193c821109109b2f432921b90823bd8a9506979',
  client_patch_pkg: 'NB_CLT_7.5.0.7',
  client_patch_response: 'response.patch',

  client_appliance_ver: '7.6.1.1',
  client_appliance_dir: 'SYMCnbclient_Linux_7.6.1.1',
  client_appliance_tar: 'netbackup_client_linux-7.6.1.1.tar',
  client_appliance_tar_kb: '500000',
  client_appliance_url: 'http://jyaskus.com.s3-website-us-west-2.amazonaws.com/files',
  client_appliance_sum: 'fc894a7072fec98b5a2c0a51d7d098b015709288eff59e6fa3debb1e42c2e879',
  client_appliance_pkg: 'NB_CLT_7.6.1.1',
  client_appliance_response: 'response.install'
}
default['netbackup']['rhel'] = {
  net_buffer_size_bytes: '262144',
  net_buffer_file: 'NET_BUFFER_SZ',
  target_dir: '/usr/openv/netbackup',
  config_file: 'bp.conf',

  client_base_ver: '7.5',
  client_base_dir: 'NetBackup_7.5_CLIENTS',
  client_base_url: 'http://jyaskus.com.s3-website-us-west-2.amazonaws.com/files',
  client_base_tar: 'netbackup_client_linux-7.5-base.tar',
  client_base_tar_kb: '700000',
  client_base_sum: 'e5723ccc9d4aefffbd52f24f39024bbed2ec4ed99292505cc6d1b1e0308c9253',
  client_base_response: 'response.install',

  client_patch_ver: '7.5.0.7',
  client_patch_dir: 'NB_update',
  client_patch_tar: 'netbackup_client_linux-7.5.0.7-patch.tar',
  client_patch_tar_kb: '400000',
  client_patch_url: 'http://jyaskus.com.s3-website-us-west-2.amazonaws.com/files',
  client_patch_sum: '5e7dd2377618d10bab3d5cb0a193c821109109b2f432921b90823bd8a9506979',
  client_patch_pkg: 'NB_CLT_7.5.0.7',
  client_patch_response: 'response.patch',

  client_appliance_ver: '7.6.1.1',
  client_appliance_dir: 'SYMCnbclient_Linux_7.6.1.1',
  client_appliance_tar: 'netbackup_client_linux-7.6.1.1.tar',
  client_appliance_tar_kb: '500000',
  client_appliance_url: 'http://jyaskus.com.s3-website-us-west-2.amazonaws.com/files',
  client_appliance_sum: 'fc894a7072fec98b5a2c0a51d7d098b015709288eff59e6fa3debb1e42c2e879',
  client_appliance_pkg: 'NB_CLT_7.6.1.1',
  client_appliance_response: 'response.install'
}
default['netbackup']['solaris2'] = {
  net_buffer_size_bytes: '262144',
  net_buffer_file: 'NET_BUFFER_SZ',
  target_dir: '/usr/openv/netbackup',
  config_file: 'bp.conf',

  client_base_ver: '7.5',
  client_base_dir: 'NetBackup_7.5_CLIENTS',
  client_base_url: 'http://jyaskus.com.s3-website-us-west-2.amazonaws.com/files',
  client_base_tar: 'netbackup_client_linux-7.5-base.tar',
  client_base_tar_kb: '700000',
  client_base_sum: 'e5723ccc9d4aefffbd52f24f39024bbed2ec4ed99292505cc6d1b1e0308c9253',
  client_base_response: 'response.install',

  client_patch_ver: '7.5.0.7',
  client_patch_dir: 'NB_update',
  client_patch_tar: 'netbackup_client_linux-7.5.0.7-patch.tar',
  client_patch_tar_kb: '400000',
  client_patch_url: 'http://jyaskus.com.s3-website-us-west-2.amazonaws.com/files',
  client_patch_sum: '5e7dd2377618d10bab3d5cb0a193c821109109b2f432921b90823bd8a9506979',
  client_patch_pkg: 'NB_CLT_7.5.0.7',
  client_patch_response: 'response.patch',

  client_appliance_ver: '7.6.1.1',
  client_appliance_dir: 'SYMCnbclient_Linux_7.6.1.1',
  client_appliance_tar: 'netbackup_client_linux-7.6.1.1.tar',
  client_appliance_tar_kb: '500000',
  client_appliance_url: 'http://jyaskus.com.s3-website-us-west-2.amazonaws.com/files',
  client_appliance_sum: 'fc894a7072fec98b5a2c0a51d7d098b015709288eff59e6fa3debb1e42c2e879',
  client_appliance_pkg: 'NB_CLT_7.6.1.1',
  client_appliance_response: 'response.install'
}
