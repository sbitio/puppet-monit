# monit
#
# This class is the responsible of installing and configuring the Monit
# service. Almost all configuration options for `monitrc` are exposed as class
# parameters.
#
# In addition to Monit configuration options, this class accepts other parameters:
#
#  * `init_system`, to set globally the default init system for `service` checks.
#  * `checks`, to provide checks from Hiera.
#  * `hiera_merge_strategy` Merge strategy for monit::checks.
#
# Lastly, this class also configures a `system` check with sane defaults. It can
# be disabled or tweaked to fit your needs. See the set of parameters
# starting with `system_`.
#
#
# @param service_enable Boolean Whether to enable the monit service.
# @param service_ensure Enum['running', 'stopped'] Ensure status of the monit service.
# @param conf_file [Stdlib::Absolutepath] Path to the Monit main configuration file.
# @param conf_dir [Stdlib::Absolutepath] Path to the Monit configuration directory (where checks are placed).
# @param conf_purge [Boolean] Whether to purge checks not managed by Puppet.
# @param check_interval [Integer] Check services at given interval.
# @param check_start_delay [Integer] Delay the first check after Monit starts by this interval.
# @param logfile Variant[Stdlib::Absolutepath, Pattern['^syslog( facility [_a-zA-Z0-9]+)?$']] Path to a logfile or syslog logging facility.
# @param idfile Stdlib::Absolutepath Path to the Monit instance unique id file.
# @param statefile Stdlib::Absolutepath Path to the persistent state file.
# @param eventqueue Boolean Whether to enable the event queue.
# @param eventqueue_basedir Stdlib::Absolutepath Path to the event queue directory.
# @param eventqueue_slots Integer Size of the event queue.
# @param mmonit_url Optional[Stdlib::Httpurl] M/Monit url.
# @param mailserver Optional[String] List of mail servers for alert delivery.
# @param mailformat_from String Override FROM field of the alert mail format.
# @param mailformat_replyto Optional[String] Override REPLYTO field of the alert mail format. NOTE: reply-to available since Monit 5.
# @param mailformat_subject Optional[String] Override SUBJECT field of the alert mail format.
# @param mailformat_message Optional[String] Override MESSAGE field of the alert mail format.
# @param alerts Array[String] Alert recipients. Alerts may be restricted on events by using a filter.
# @param httpserver Boolean Whether to enable the embedded webserver.
# @param httpserver_port Integer[1024, 65535] Webserver port.
# @param httpserver_bind_address String Webserver bind address.
# @param httpserver_ssl Boolean Whether to enable SSL for the webserver.
# @param httpserver_pemfile Optional[Stdlib::Absolutepath] Webserver SSL certificate file.
# @param httpserver_allow Array[String] Webserver grants.
# @param init_system Enum['sysv', 'systemd', 'upstart'] Default init system. Used to build service checks.
# @param service_program Stdlib::Absolutepath Path to the default init system program.
# @param system_check_ensure Enum['present', 'absent'] Whether to create the system check.
# @param system_loadavg_1min Numeric 1 minute load average threshold.
# @param system_loadavg_5min Numeric 5 minute load average threshold.
# @param system_loadavg_15min Numeric 15 minute load average threshold.
# @param system_cpu_user String CPU user usage threshold.
# @param system_cpu_system String CPU system usage threshold.
# @param system_cpu_wait String CPU wait usage threshold.
# @param system_memory String Memory usage threshold.
# @param system_swap Optional[String] Swap usage threshold. NOTE: swap available since monit 5.2.
# @param system_fs Variant[Array[Stdlib::Absolutepath], Array[Pattern['^/']]] Path to filesystems to check.
# @param system_fs_space_usage String Filesystem space usage threshold.
# @param system_fs_inode_usage String Filesystem inode usage threshold.
# @param checks Hash[String, Hash] Hash of additional checks to create.
# @param hiera_merge_strategy Optional[Enum['hiera_hash']] Merge strategy when obtaining checks from Hiera.
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

