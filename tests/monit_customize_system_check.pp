class { '::monit':
  system_cpu_wait       => '40%',
  system_memory         => '84%',
  system_loadavg_1min   => 14,
  system_fs_space_usage => '88%',
  system_fs             => ['/', '/mnt/backups'],
}
