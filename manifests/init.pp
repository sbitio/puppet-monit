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
  Boolean $service_enable                  = true,
  Enum[
    'running',
    'stopped'
    ] $service_ensure                      = 'running',
  Stdlib::Absolutepath $conf_file          = $monit::params::conf_file,
  Stdlib::Absolutepath $conf_dir           = $monit::params::conf_dir,
  Boolean $conf_purge                      = true,
  Integer $check_interval                  = $monit::params::check_interval,
  Integer $check_start_delay               = $monit::params::check_start_delay,
  # $logfile can be an absolute path or
  # a string of the form "syslog facility log_daemon"
  Variant[
    Stdlib::Absolutepath,
    Pattern['^syslog( facility [_a-zA-Z0-9]+)?$']
    ] $logfile                             = $monit::params::logfile,
  Stdlib::Absolutepath $idfile             = $monit::params::idfile,
  Stdlib::Absolutepath $statefile          = $monit::params::statefile,
  Boolean $eventqueue                      = $monit::params::eventqueue,
  Stdlib::Absolutepath $eventqueue_basedir = '/var/monit',
  Integer $eventqueue_slots                = 100,
  Optional[Stdlib::Httpurl] $mmonit_url    = undef,
  Optional[String] $mailserver             = undef,
  String $mailformat_from                  = "monit@${::fqdn}",
  # NOTE: reply-to available since monit 5.2
  Optional[String] $mailformat_replyto     = undef,
  Optional[String] $mailformat_subject     = undef,
  Optional[String] $mailformat_message     = undef,
  Array[String] $alerts                    = [],
  Boolean $httpserver                      = true,
  Integer[1024, 65535] $httpserver_port    = 2812,
  String $httpserver_bind_address          = 'localhost',
  Boolean $httpserver_ssl                  = false,
  Optional[
    Stdlib::Absolutepath
    ] $httpserver_pemfile                  = undef,
  Array[String] $httpserver_allow          = [ 'localhost' ],
  # Init system defaults.
  Enum[
    'sysv',
    'systemd',
    'upstart'
    ] $init_system                         = $monit::params::init_system,
  Stdlib::Absolutepath $service_program    = $monit::params::service_program,
  # System resources check.
  Enum[
    'present',
    'absent'
    ] $system_check_ensure                 = 'present',
  Numeric $system_loadavg_1min               = 3 * $processorcount,
  Numeric $system_loadavg_5min               = 1.5 * $processorcount,
  Numeric $system_loadavg_15min              = 1.5 * $processorcount,
  String $system_cpu_user                  = '75%',
  String $system_cpu_system                = '30%',
  String $system_cpu_wait                  = '30%',
  String $system_memory                    = '75%',
  # NOTE: swap available since monit 5.2.
  Optional[String] $system_swap            = undef,
  Variant[
    Array[Stdlib::Absolutepath],
    Array[Pattern['^/']]
    ] $system_fs                           = ['/',],
  String $system_fs_space_usage            = '80%',
  String $system_fs_inode_usage            = '80%',
  # Additional checks.
  Hash[String, Hash] $checks               = {},
  Optional[Enum[
    'hiera_hash'
    ]] $hiera_merge_strategy               = undef,
) inherits monit::params {

  class{'monit::install': } ->
  class{'monit::config': } ~>
  class{'monit::service': } ->
  Class['monit']

}

