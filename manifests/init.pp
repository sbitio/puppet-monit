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
  $httpserver              = false,
  $httpserver_port         = 2812,
  $httpserver_bind_address = 'localhost',
  $httpserver_ssl          = false,
  $httpserver_pemfile      = undef,
  $httpserver_allow        = [],
  # System resources check.
  $system_check_ensure     = present,
  $system_loadavg_1min     = 3 * $processorcount,
  $system_loadavg_5min     = 1.5 * $processorcount,
  $system_loadavg_15min    = 1.5 * $processorcount,
  $system_cpu_user         = '75%',
  $system_cpu_system       = '30%',
  $system_cpu_wait         = '30%',
  $system_memory           = '75%',
  $system_swap             = '5%',
  $system_fs               = ['/',],
  $system_fs_space_usage   = '80%',
  $system_fs_inode_usage   = '80%',
  # Additional checks.
  $checks                  = {},

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
  validate_array($alerts)
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

  # System resources check.
  $ensure_options = [ present, absent ]
  if ! ($system_check_ensure in $ensure_options) {
    fail("Invalid ensure parameter. Valid values: ${ensure_options}")
  }
  # Validate number?
  #  $system_loadavg_1min,
  #  $system_loadavg_5min,
  #  $system_loadavg_15min,
  validate_string(
    $system_memory,
    $system_swap,
    $system_cpu_user,
    $system_cpu_system,
    $system_cpu_wait,
    $system_swap,
    $system_fs_space_usage,
    $system_fs_inode_usage,
  )
  validate_array($system_fs)

  monit::check::system {"${::fqdn}":
    priority => '10',
    group    => 'system',
    bundle   => 'system',
    order    => 0,
    tests    => parseyaml(template('monit/system_test_resources.erb')),
  }

  $system_test_fs_defaults = {
    priority => '10',
    group    => 'system',
    bundle   => 'system',
    order    => 1,
    tests    => $tests,
  }
  $system_test_fs = parseyaml(template('monit/system_test_filesystems.erb'))
  create_resources("monit::check::filesystem", $system_test_fs, $system_test_fs_defaults)

  # Additional checks.
  validate_hash($checks)
  create_resources('monit::check', $checks)
}

