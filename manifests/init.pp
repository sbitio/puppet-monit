# == Class: monit
#
# This class is the entrance point to install and configure monit service.
#
class monit(
  $conf_file  = $monit::params::conf_file,
  $conf_dir   = $monit::params::conf_dir,
  $conf_purge = true,
) inherits monit::params {
  class{'monit::install': } ->
  class{'monit::config': } ~>
  class{'monit::service': } ->
  Class["monit"]
}

