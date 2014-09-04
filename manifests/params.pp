class monit::params {
  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  $package = 'monit'
  $service = 'monit'

  $check_interval    = 120
  $check_start_delay = 240

  case $::osfamily {
    'Debian': {
      $conf_file  = '/etc/monit/monitrc'
      $conf_dir   = '/etc/monit/conf.d'
      $logfile    = '/var/log/monit.log'
      $idfile     = '/var/lib/monit/id'
      $statefile  = '/var/lib/monit/state'
      $eventqueue = true
    }
    'RedHat': {
      $conf_file  = '/etc/monit.conf'
      $conf_dir   = '/etc/monit.d'
      $logfile    = '/var/log/monit'
      $idfile     = undef
      $statefile  = undef
      $eventqueue = false
    }
  }
}

