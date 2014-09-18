class monit::config {

  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  # Monit conf file and directory.
  validate_absolute_path($monit::conf_file)
  file { $monit::conf_file:
    ensure  => present,
    content => template('monit/conf_file.erb'),
  }
  validate_absolute_path($monit::conf_dir)
  file { $monit::conf_dir:
    ensure  => directory,
    recurse => true,
    purge   => $monit::conf_purge,
  }

  # Monit configuration options for the tpl.
  #$logfile may be some as "syslog facility log_daemon"
  # so validating abs path is inacurate.
  # validate_absolute_path($monit::logfile)
  if $monit::idfile {
    validate_absolute_path($monit::idfile)
  }
  if $monit::statefile {
    validate_absolute_path($monit::statefile)
  }
  validate_bool($monit::eventqueue)
  validate_array($monit::alerts)
  validate_bool($monit::httpserver)
  validate_bool($monit::httpserver_ssl)
  if $monit::httpserver_ssl {
    validate_absolute_path($monit::httpserver_pemfile)
  }
  validate_array($monit::httpserver_allow)
  file { "$monit::conf_dir/00_monit_config":
    ensure  => present,
    content => template('monit/conf_file_overrides.erb'),
  }

  # System resources check.
  $ensure_options = [ present, absent ]
  if ! ($monit::system_check_ensure in $ensure_options) {
    fail("Invalid ensure parameter. Valid values: ${ensure_options}")
  }
  if $system_check_ensure == present {
    # Validate number?
    #  $monit::system_loadavg_1min,
    #  $monit::system_loadavg_5min,
    #  $monit::system_loadavg_15min,
    validate_string(
      $monit::system_memory,
      $monit::system_swap,
      $monit::system_cpu_user,
      $monit::system_cpu_system,
      $monit::system_cpu_wait,
      $monit::system_swap,
      $monit::system_fs_space_usage,
      $monit::system_fs_inode_usage,
    )
    validate_array($monit::system_fs)

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
  }

  # Additional checks.
  validate_hash($monit::checks)
  create_resources('monit::check', $monit::checks)

}

