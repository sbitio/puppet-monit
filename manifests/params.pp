class monit::params {
  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  $package = 'monit'
  $service = 'monit'

  case $::osfamily {
    'Debian': {
      $conf_file = '/etc/monit/monitrc'
      $conf_dir  = '/etc/monit/conf.d'
    }
    'RedHat': {
      $conf_file = '/etc/monit.conf'
      $conf_dir  = '/etc/monit.d'
    }
  }
}

