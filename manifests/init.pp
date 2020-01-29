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
#
# Lastly, this class also configures a `system` check with sane defaults. It can
# be disabled or tweaked to fit your needs. See the set of parameters
# starting with `system_`.
#
#
# @param service_enable
#   Whether to enable the monit service.
# @param service_ensure
#   Ensure status of the monit service.
# @param conf_file
#   Path to the Monit main configuration file.
# @param conf_dir
#   Path to the Monit configuration directory (where checks are placed).
# @param conf_purge
#   Whether to purge checks not managed by Puppet.
# @param check_interval
#   Check services at given interval.
# @param check_start_delay
#   Delay the first check after Monit starts by this interval.
# @param logfile
#   Path to a logfile or syslog logging facility.
# @param idfile
#   Path to the Monit instance unique id file.
# @param statefile
#   Path to the persistent state file.
# @param eventqueue
#   Whether to enable the event queue.
# @param eventqueue_basedir
#   Path to the event queue directory.
# @param eventqueue_slots
#   Size of the event queue.
# @param mmonit_url
#   M/Monit url.
# @param mailserver
#   List of mail servers for alert delivery.
# @param mailformat_from
#   Override FROM field of the alert mail format.
# @param mailformat_replyto
#   Override REPLYTO field of the alert mail format. NOTE: reply-to available since Monit 5.
# @param mailformat_subject
#   Override SUBJECT field of the alert mail format.
# @param mailformat_message
#   Override MESSAGE field of the alert mail format.
# @param alerts
#   Alert recipients. Alerts may be restricted on events by using a filter.
# @param httpserver
#   Whether to enable the embedded webserver.
# @param httpserver_port
#   Webserver port.
# @param httpserver_bind_address
#   Webserver bind address.
# @param httpserver_ssl
#   Whether to enable SSL for the webserver.
# @param httpserver_pemfile
#   Webserver SSL certificate file.
# @param httpserver_allow
#   Webserver grants.
# @param init_system
#   Default init system. Used to build service checks.
# @param service_program
#   Path to the default init system program.
# @param system_check_ensure
#   Whether to create the system check.
# @param system_loadavg_1min
#   1 minute load average threshold.
# @param system_loadavg_5min
#   5 minute load average threshold.
# @param system_loadavg_15min
#   15 minute load average threshold.
# @param system_cpu_user
#   CPU user usage threshold.
# @param system_cpu_system
#   CPU system usage threshold.
# @param system_cpu_wait
#   CPU wait usage threshold.
# @param system_memory
#   Memory usage threshold.
# @param system_swap
#   Swap usage threshold. NOTE: swap available since monit 5.2.
# @param system_fs
#   Path to filesystems to check. If empty, will check all mounted filesystems, but the ones with a type in $monit::fs_banned_types.
# @param system_fs_space_usage
#   Filesystem space usage threshold.
# @param system_fs_inode_usage
#   Filesystem inode usage threshold.
# @param fs_banned_types
#   List of filesystem types to ignore in generation of $monit::system_fs.
# @param checks
#   Hash of additional checks to create.
# @param hiera_merge_strategy
#   Merge strategy when obtaining checks from Hiera. **Deprecated** use instead hiera 5 [`lookup_options`](https://puppet.com/docs/puppet/latest/hiera_merging.html).
#
class monit(
  Boolean $service_enable                   = true,
  Enum[
    'running',
    'stopped'
    ] $service_ensure                       = 'running',
  Stdlib::Absolutepath $conf_file           = $monit::params::conf_file,
  Stdlib::Absolutepath $conf_dir            = $monit::params::conf_dir,
  Boolean $conf_purge                       = true,
  Integer $check_interval                   = $monit::params::check_interval,
  Integer $check_start_delay                = $monit::params::check_start_delay,
  # $logfile can be an absolute path or
  # a string of the form "syslog facility log_daemon"
  Variant[
    Stdlib::Absolutepath,
    Pattern['^syslog( facility [_a-zA-Z0-9]+)?$']
    ] $logfile                              = $monit::params::logfile,
  Stdlib::Absolutepath $idfile              = $monit::params::idfile,
  Stdlib::Absolutepath $statefile           = $monit::params::statefile,
  Boolean $eventqueue                       = $monit::params::eventqueue,
  Stdlib::Absolutepath $eventqueue_basedir  = '/var/monit',
  Integer $eventqueue_slots                 = 100,
  Optional[Stdlib::Httpurl] $mmonit_url     = undef,
  Optional[String] $mailserver              = undef,
  String $mailformat_from                   = "monit@${::fqdn}",
  # NOTE: reply-to available since monit 5.2
  Optional[String] $mailformat_replyto      = undef,
  Optional[String] $mailformat_subject      = undef,
  Optional[String] $mailformat_message      = undef,
  Array[String] $alerts                     = [],
  Boolean $httpserver                       = true,
  Integer[1024, 65535] $httpserver_port     = 2812,
  Optional[String] $httpserver_bind_address = undef,
  Boolean $httpserver_ssl                   = false,
  Optional[
    Stdlib::Absolutepath
    ] $httpserver_pemfile                   = undef,
  Array[String] $httpserver_allow           = [ 'localhost' ],
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
  Numeric $system_loadavg_1min             = (3 * $::processorcount),
  Numeric $system_loadavg_5min             = (1.5 * $::processorcount),
  Numeric $system_loadavg_15min            = (1.5 * $::processorcount),
  String $system_cpu_user                  = '75%',
  String $system_cpu_system                = '30%',
  String $system_cpu_wait                  = '30%',
  String $system_memory                    = '75%',
  # NOTE: swap available since monit 5.2.
  Optional[String] $system_swap            = undef,
  Variant[
    Array[Stdlib::Absolutepath],
    Array[Pattern['^/']]
    ] $system_fs                           = [],
  String $system_fs_space_usage            = '80%',
  String $system_fs_inode_usage            = '80%',
  Array[String] $fs_banned_types           = ['devpts', 'devtmpfs', 'hugetlbfs', 'mqueue', 'nsfs', 'overlay', 'rpc_pipefs', 'tmpfs'],
  # Additional checks.
  Hash[String, Hash] $checks               = {},
  Optional[Enum[
    'hiera_hash'
    ]] $hiera_merge_strategy               = undef,
) inherits monit::params {

  if !empty($hiera_merge_strategy) {
    warning('\$hiera_merge_strategy parameter is deprecated and will be removed in future versions! Please use Hiera 5 `lookup_options` instead. See https://puppet.com/docs/puppet/latest/hiera_merging.html')
  }
  class{'monit::install': }
  -> class{'monit::config': }
  ~> class{'monit::service': }
  -> Class['monit']

}

