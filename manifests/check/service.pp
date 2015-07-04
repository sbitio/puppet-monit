define monit::check::service(
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

  # Check type specific.
  $template        = undef,
  $pidfile         = undef,
  $matching        = undef,
  $binary          = "/usr/sbin/${name}",
  $init_system     = $monit::init_system,
  $initd           = undef,
  $sysv_file       = "/etc/init.d/${name}",
  $upstart_file    = "/etc/init/${name}.conf",
  $systemd_file    = "/usr/lib/systemd/system/${name}.service",

  # Params for process type.
  $uid             = undef,
  $gid             = undef,
  $program_start   = "${monit::service_program} ${name} start",
  $program_stop    = "${monit::service_program} ${name} stop",
  $timeout         = undef,
  $timeout_start   = undef,
  $timeout_stop    = undef,
) {

  validate_absolute_path($binary)

  if $initd {
    warning("monit::check::service: parameter 'initd' is deprecated in favour of 'sysv_file'")
  }

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
    'group'      => $group,
    'alerts'     => $alerts,
    'noalerts'   => $noalerts,
    'depends'    => $depends,
    'priority'   => $priority,
    'bundle'     => $bundle,
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
  ensure_resource("monit::check::process", "${name}_process", merge($defaults, $params_process))

  # Check service file.
  $params_service_file = {
    'path'       => $service_file,
    'bundle'     => $bundle,
    'order'      => inline_template("<%= @order.to_i + 1 %>"),
  }
  ensure_resource("monit::check::file", "${name}_service_file", merge($defaults, $params_service_file))

  # Check service binary.
  $params_binary = {
    'path'       => $binary,
    'bundle'     => $bundle,
    'order'      => inline_template("<%= @order.to_i + 2 %>"),
  }
  ensure_resource("monit::check::file", "${name}_binary", merge($defaults, $params_binary))
}

