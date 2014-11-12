# == Class: monit
#
# This class is the entrance point to install and configure monit service.
#
# === Parameters
#
# [*alerts*]
#   Array of emails with optional event filters.
#   e.g:
#   - "foo@bar"
#   - "foo@bar only on { timeout, nonexist }"
#   - "foo@bar but not on { instance }"
#
#   Monit doc reference: http://mmonit.com/monit/documentation/monit.html#setting_an_alert_recipient
#
class monit(
  $service_enable          = true,
  $service_ensure          = running,
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
  $mailformat_from         = "monit@${::fqdn}",
  # NOTE: reply-to available since monit 5.2
  $mailformat_replyto      = undef,
  $mailformat_subject      = undef,
  $mailformat_message      = undef,
  $alerts                  = [],
  $httpserver              = true,
  $httpserver_port         = 2812,
  $httpserver_bind_address = 'localhost',
  $httpserver_ssl          = false,
  $httpserver_pemfile      = undef,
  $httpserver_allow        = [ 'localhost' ],
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
) inherits monit::params {

  class{'monit::install': } ->
  class{'monit::config': } ~>
  class{'monit::service': } ->
  Class["monit"]

}

