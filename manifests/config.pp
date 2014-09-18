class monit::config(
  # System resources check.
  $system_check_ensure     = present,
  $system_loadavg_1min     = 3 * $processorcount,
  $system_loadavg_5min     = 1.5 * $processorcount,
  $system_loadavg_15min    = 1.5 * $processorcount,
  $system_cpu_user         = '75%',
  $system_cpu_system       = '30%',
  $system_cpu_wait         = '30%',
  $system_memory           = '75%',
  # NOTE: swap available since monit 5.2
  $system_swap             = undef,
  $system_fs               = ['/',],
  $system_fs_space_usage   = '80%',
  $system_fs_inode_usage   = '80%',
  # Additional checks.
  $checks                  = {},
) {

  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  file { $monit::conf_file:
    ensure  => present,
    content => template('monit/conf_file.erb'),
  }
  file { $monit::conf_dir:
    ensure  => directory,
    recurse => true,
    purge   => $monit::conf_purge,
  }
  file { "$monit::conf_dir/00_monit_config":
    ensure  => present,
    content => template('monit/conf_file_overrides.erb'),
  }

  # System resources check.
  $ensure_options = [ present, absent ]
  if ! ($system_check_ensure in $ensure_options) {
    fail("Invalid ensure parameter. Valid values: ${ensure_options}")
  }
  # Validate number?
  #  $system_loadavg_1min,
  #  $system_loadavg_5min,
  #  $system_loadavg_15min,
  validate_string(
    $system_memory,
    $system_swap,
    $system_cpu_user,
    $system_cpu_system,
    $system_cpu_wait,
    $system_swap,
    $system_fs_space_usage,
    $system_fs_inode_usage,
  )
  validate_array($system_fs)

  monit::check::system {"${::fqdn}":
    priority => '10',
    group    => 'system',
    order    => 0,
    tests    => parseyaml(template('monit/system_test_resources.erb')),
  }

  $system_test_fs_defaults = {
    priority => '10',
    group    => 'system',
    bundle   => $::fqdn,
    order    => 1,
  }
  $system_test_fs = parseyaml(template('monit/system_test_filesystems.erb'))
  create_resources("monit::check::filesystem", $system_test_fs, $system_test_fs_defaults)

  # Additional checks.
  validate_hash($checks)
  create_resources('monit::check', $checks)

}

