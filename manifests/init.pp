# == Class: monit
#
# This class is the entrance point to install and configure monit service.
#
class monit(
  $conf_file               = $monit::params::conf_file,
  $conf_dir                = $monit::params::conf_dir,
  $conf_purge              = true,
  $check_interval          = $monit::params::check_interval,
  $check_start_delay       = $monit::params::check_start_delay,
  $logfile                 = $monit::params::logfile,
  $idfile                  = $monit::params::idfile,
  $statefile               = $monit::params::statefile,
  $eventqueue              = $monit::params::eventqueue,
  $eventqueue_basedir      = '/var/monit',
  $eventqueue_slots        = 100,
  $mmonit_url              = undef,
  $mailserver              = undef,
  $mailformat_from         = "monit@${::hostname}",
  # NOTE: reply-to available since monit 5.2
  $mailformat_replyto      = undef,
  $mailformat_subject      = undef,
  $mailformat_message      = undef,
  $alert                   = [],
  $httpserver              = false,
  $httpserver_port         = 2812,
  $httpserver_bind_address = 'localhost',
  $httpserver_ssl          = false,
  $httpserver_pemfile      = undef,
  $httpserver_allow        = [],
) inherits monit::params {
  validate_absolute_path($conf_file)
  validate_absolute_path($conf_dir)
  #$logfile may be some as "syslog facility log_daemon"
  # so validating abs path is inacurate.
  # validate_absolute_path($logfile)
  if $idfile {
    validate_absolute_path($idfile)
  }
  if $statefile {
    validate_absolute_path($statefile)
  }
  validate_bool($eventqueue)
  validate_array($alert)
  validate_bool($httpserver)
  validate_bool($httpserver_ssl)
  if $httpserver_ssl {
    validate_absolute_path($httpserver_pemfile)
  }
  validate_array($httpserver_allow)

  class{'monit::install': } ->
  class{'monit::config': } ~>
  class{'monit::service': } ->
  Class["monit"]
}

