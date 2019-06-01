# monit::config
# @api private
#
# This class handles the module data.
#
class monit::params {

  # $caller_module_name is empty when inherited?
  #iif $caller_module_name != $module_name {
  #  warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  #}

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

      $service_program = '/usr/sbin/service'
      case $::operatingsystem {
        'Debian': {
          if versioncmp($::lsbmajdistrelease, '8') < 0 {
            $init_system = 'sysv'
          }
          else {
            $init_system     = 'systemd'
            $systemd_unitdir = '/lib/systemd/system'
          }
        }
        'Ubuntu': {
          $init_system = 'upstart'
        }
        default: {
          fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support operatingsystem Debian and Ubuntu on osfamily Debian")
        }
      }
    }
    'FreeBSD': {
      $conf_file  = '/usr/local/etc/monitrc'
      $conf_dir   = '/usr/local/etc/monit.d'
      $logfile    = '/var/log/monit'
      $idfile     = undef
      $statefile  = undef
      $eventqueue = false

      $service_program = '/usr/sbin/service'
      $init_system = 'sysv'
    }
    'RedHat': {
      $conf_file  = '/etc/monit.conf'
      $conf_dir   = '/etc/monit.d'
      $logfile    = '/var/log/monit'
      $idfile     = undef
      $statefile  = undef
      $eventqueue = false

      $service_program = '/sbin/service'
      if versioncmp($::lsbmajdistrelease, '7') < 0 {
        $init_system = 'sysv'
      }
      else {
        $init_system = 'systemd'
        $systemd_unitdir = '/usr/lib/systemd/system'
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily Debian and RedHat")
    }
  }
}

