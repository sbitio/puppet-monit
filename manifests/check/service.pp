# monit::check::service
#
# Implements a compound check type for system services.
# It is a bundle of PROCESS and FILE checks.
#
#
# @param template
#   Not used. This parameter is here for consistency with other check types. See `monit::check` for details.
# @param binary
#   Path to the service binary. Used to declare a FILE check.
# @param init_system
#   Type of init system this script uses.
# @param sysv_file
#   If `init_system` is sysv. This is the path to the init script. Otherwise ignored.
# @param upstart_file
#   If `init_system` is upstart. This is the path to the system job. Otherwise ignored.
# @param systemd_file
#   If `init_system` is systemd. This is the path to the unit configuration file. Otherwise ignored.
# @param program_start
#   Command to start the service.
# @param program_stop
#   Command to stop the service.
# @param pidfile
#   Path to the PID file of the service.
# @param matching
#   If the service doesn't provide a PID file, use this option to pass a regex pattern to check the process list.
# @param uid
#   UID of the process.
# @param gid
#   GID of the process.
# @param timeout
#   Timeout on the start/stop operations.
# @param timeout_start
#   Timeout on the start operation. Generic timeout will be used if not specified.
# @param timeout_stop
#   Timeout on the stop operation. Generic timeout will be used if not specified.
# @param ensure
#   Whether this check must be present or absent.
# @param group
#   Monit group.
# @param every
#   Service poll time
# @param alerts
#   Alert recipients (with event filters) to set.
# @param noalerts
#   Alerts to disable for this check.
# @param tests
#   Monit tests.
# @param depends
#   Dependencies of this check on other checks.
# @param priority
#   Used as a prefix for the filename generated. Load order doesn't matter to Monit.
#   This is just a facility to organize your checks by filename.
# @param bundle
#   Used to group checks by filename. All checks in the same bundle will be added to the same filename.
# @param order
#   Order of the check within the bundle filename.
#
define monit::check::service(
  # Check type specific.
  Undef $template                         = undef,
  Stdlib::Absolutepath $binary            = "/usr/sbin/${name}",
  Enum[
    'sysv',
    'systemd',
    'upstart'
    ] $init_system                        = $monit::init_system,
  Stdlib::Absolutepath $sysv_file         = "/etc/init.d/${name}",
  Stdlib::Absolutepath $upstart_file      = "/etc/init/${name}.conf",
  Stdlib::Absolutepath $systemd_file      = "${monit::params::systemd_unitdir}/${name}.service",

  # Params for process type.
  String $program_start                   = "${monit::service_program} ${name} start",
  String $program_stop                    = "${monit::service_program} ${name} stop",
  Optional[Stdlib::Absolutepath] $pidfile = undef,
  Optional[String] $matching              = undef,
  Optional[Integer] $uid                  = undef,
  Optional[Integer] $gid                  = undef,
  Optional[Numeric] $timeout              = undef,
  Optional[Numeric] $timeout_start        = undef,
  Optional[Numeric] $timeout_stop         = undef,

  # Common parameters.
  Monit::Check::Ensure $ensure            = 'present',
  String $group                           = $name,
  String $every                           = '',
  Array[String] $alerts                   = [],
  Array[String] $noalerts                 = [],
  Monit::Check::Tests $tests              = [],
  Array[String] $depends                  = [],
  String $priority                        = '20',
  String $bundle                          = $name,
  Integer $order                          = 0,
) {

  case $init_system {
    'sysv': {
      $service_file = $sysv_file
    }
    'upstart': {
      $service_file = $upstart_file
    }
    'systemd': {
      $service_file = $systemd_file
    }
    default: {
      fail("Unknown init system: ${init_system}.")
    }
  }

  $defaults = {
    'ensure'     => $ensure,
    'priority'   => $priority,
    'bundle'     => $bundle,
    'group'      => $group,
    'depends'    => $depends,
    'every'      => $every,
    'alerts'     => $alerts,
    'noalerts'   => $noalerts,
  }

  # Check service process.
  $depends_all = union($depends, ["${name}_service_file", "${name}_binary"])
  $params_process = {
    'name'          => $name,
    'depends'       => $depends_all,
    'tests'         => $tests,
    'pidfile'       => $pidfile,
    'matching'      => $matching,
    'uid'           => $uid,
    'gid'           => $gid,
    'program_start' => $program_start,
    'program_stop'  => $program_stop,
    'bundle'        => $bundle,
    'order'         => $order,
    'timeout'       => $timeout,
    'timeout_start' => $timeout_start,
    'timeout_stop'  => $timeout_stop,
  }
  ensure_resource('monit::check::process', "${name}_process", merge($defaults, $params_process))

  # Check service file.
  $params_service_file = {
    'path'       => $service_file,
    'bundle'     => $bundle,
    'order'      => Integer(inline_template('<%= @order.to_i + 1 %>')),
  }
  ensure_resource('monit::check::file', "${name}_service_file", merge($defaults, $params_service_file))

  # Check service binary.
  $params_binary = {
    'path'       => $binary,
    'bundle'     => $bundle,
    'order'      => Integer(inline_template('<%= @order.to_i + 2 %>')),
  }
  ensure_resource('monit::check::file', "${name}_binary", merge($defaults, $params_binary))
}
