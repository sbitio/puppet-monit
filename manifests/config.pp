class monit::config {
  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  file { $monit::conf_file:
    ensure  => present,
    content => template('monit/conf_file.pp'),
  }
  file { $monit::conf_dir:
    ensure  => directory,
    recurse => true,
    purge   => $monit::conf_purge,
  }
  file { "$monit::conf_dir/00_monit_config":
    ensure  => present,
    content => template('monit/conf_file_overrides.pp'),
  }
}

