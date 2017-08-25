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
  # Common parameters.
  Enum[
    'present',
    'absent'
    ] $ensure             = present,
  String $group           = $name,
  Array[String] $alerts   = [],
  Array[String] $noalerts = [],
  Array[
    Hash[String, String]
    ] $tests              = [],
  Array[String] $depends  = [],
  String $priority        = '20',
  String $bundle          = $name,
  Integer $order          = 0,

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
  Optional[Stdlib::Absolutepath] $pidfile = undef,
  Optional[String] $matching              = undef,
  Optional[Integer] $uid                  = undef,
  Optional[Integer] $gid                  = undef,
  String $program_start                   = "${monit::service_program} ${name} start",
  String $program_stop                    = "${monit::service_program} ${name} stop",
  Optional[Numeric] $timeout              = undef,
  Optional[Numeric] $timeout_start        = undef,
  Optional[Numeric] $timeout_stop         = undef,
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
    'order'      => 0 + inline_template('<%= @order.to_i + 1 %>'),
  }
  ensure_resource('monit::check::file', "${name}_service_file", merge($defaults, $params_service_file))

  # Check service binary.
  $params_binary = {
    'path'       => $binary,
    'bundle'     => $bundle,
    'order'      => 0 + inline_template('<%= @order.to_i + 2 %>'),
  }
  ensure_resource('monit::check::file', "${name}_binary", merge($defaults, $params_binary))
}

