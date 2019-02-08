# == Defined type: monit::check::service
#
# Implements a compound check type for system services.
# It is a bundle of PROCESS and FILE checks.
#
# === Parameters
#
# [*template*]
#   Not used. This parameter is here for consistency with other check types.
#   See `monit::check` for details.
#
# [*binary*]
#   Path to the service binary. Used to declare a FILE check.
#
# [*init_system*]
#   Type of init system this script uses.
#   Valid values: sysv, upstart, systemd.
#   Default: Depends on OS. See `monit::params`.
#
# [*sysv_file*]
#   If `init_system` is sysv. This is the path to the init script. Otherwise ignored.
#   Default: "/etc/init.d/${name}"
#
# [*upstart_file*]
#   If `init_system` is upstart. This is the path to the system job. Otherwise ignored.
#   Default: "/etc/init/${name}.conf"
#
# [*systemd_file*]
#   If `init_system` is systemd. This is the path to the unit configuration file. Otherwise ignored.
#   Default: "${monit::params::systemd_unitdir}/${name}.service"
#
define monit::check::service(
  # Check type specific.
  $template          = undef,
  $binary            = "/usr/sbin/${name}",
  $init_system       = $monit::init_system,
  $sysv_file         = "/etc/init.d/${name}",
  $upstart_file      = "/etc/init/${name}.conf",
  $systemd_file      = "${monit::params::systemd_unitdir}/${name}.service",
  $restart_tolerance = undef,

  # Params for process type.
  $pidfile         = undef,
  $matching        = undef,
  $uid             = undef,
  $gid             = undef,
  $program_start   = "${monit::service_program} ${name} start",
  $program_stop    = "${monit::service_program} ${name} stop",
  $timeout         = undef,
  $timeout_start   = undef,
  $timeout_stop    = undef,

  # Common parameters.
  $ensure        = present,
  $group         = $name,
  $alerts        = [],
  $noalerts      = [],
  $tests         = [],
  $depends       = [],
  $priority      = '20',
  $bundle        = $name,
  $order         = 0,
) {

  validate_absolute_path($binary)

  case $init_system {
    'sysv': {
      validate_absolute_path($sysv_file)
      $service_file = $sysv_file
    }
    'upstart': {
      validate_absolute_path($upstart_file)
      $service_file = $upstart_file
    }
    'systemd': {
      validate_absolute_path($systemd_file)
      $service_file = $systemd_file
    }
    default: {
      fail("unknown init system '${init_system}'. Supported systems are: sysv, upstart, systemd.")
    }
  }

  $defaults = {
    'ensure'     => $ensure,
    'priority'   => $priority,
    'bundle'     => $bundle,
    'group'      => $group,
    'depends'    => $depends,
    'alerts'     => $alerts,
    'noalerts'   => $noalerts,
  }

  # Check service process.
  $depends_all = union($depends, ["${name}_service_file", "${name}_binary"])
  $params_process = {
    'name'              => $name,
    'depends'           => $depends_all,
    'tests'             => $tests,
    'pidfile'           => $pidfile,
    'matching'          => $matching,
    'uid'               => $uid,
    'gid'               => $gid,
    'program_start'     => $program_start,
    'program_stop'      => $program_stop,
    'bundle'            => $bundle,
    'order'             => $order,
    'timeout'           => $timeout,
    'timeout_start'     => $timeout_start,
    'timeout_stop'      => $timeout_stop,
    'restart_tolerance' => $restart_tolerance,
  }
  ensure_resource('monit::check::process', "${name}_process", merge($defaults, $params_process))

  # Check service file.
  $params_service_file = {
    'path'       => $service_file,
    'bundle'     => $bundle,
    'order'      => inline_template('<%= @order.to_i + 1 %>'),
  }
  ensure_resource('monit::check::file', "${name}_service_file", merge($defaults, $params_service_file))

  # Check service binary.
  $params_binary = {
    'path'       => $binary,
    'bundle'     => $bundle,
    'order'      => inline_template('<%= @order.to_i + 2 %>'),
  }
  ensure_resource('monit::check::file', "${name}_binary", merge($defaults, $params_binary))
}

