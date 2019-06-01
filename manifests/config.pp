# monit::config
# @api private
#
# This class handles the configuration files.
#
class monit::config {

  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  # Monit conf file and directory.
  file { $monit::conf_file:
    ensure  => present,
    mode    => '0700',
    content => template('monit/conf_file.erb'),
  }
  file { $monit::conf_dir:
    ensure  => directory,
    recurse => true,
    purge   => $monit::conf_purge,
  }

  file { "${monit::conf_dir}/00_monit_config":
    ensure  => present,
    content => template('monit/conf_file_overrides.erb'),
  }

  if $monit::system_check_ensure == present {
    monit::check::system {$::fqdn:
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
    create_resources('monit::check::filesystem', $system_test_fs, $system_test_fs_defaults)
  }

  # Additional checks.
  if ($monit::hiera_merge_strategy == 'hiera_hash') {
    $mychecks = hiera_hash('monit::checks', {})
  }
  else {
    $mychecks = $monit::checks
  }
  create_resources('monit::check', $mychecks)
}

