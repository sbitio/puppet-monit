define monit::check::service(
  # Common parameters.
  $ensure        = present,
  $check_name    = $name,
  $group         = $name,
  $alerts        = [],
  $noalerts      = [],
  $tests         = [],
  $depends       = [],
  $priority      = '',
  $bundle        = $name,
  $order         = 0,

  # Check type specific.
  $template        = undef,
  $service         = $check_name,
  $pidfile,
  $binary          = "/usr/sbin/${service}",
  $initd           = "/etc/init.d/${service}",

  # Params for process type.
  $uid             = undef,
  $gid             = undef,
  $program_start   = "${initd} start",
  $program_stop    = "${initd} stop",
  $program_restart = "${initd} restart",
  $timeout         = undef,
  $timeout_start   = $timeout,
  $timeout_stop    = $timeout,
  $timeout_restart = $timeout,
) {
  validate_absolute_path($pidfile)
  validate_absolute_path($binary)
  validate_absolute_path($initd)

  $defaults = {
    'ensure'     => $ensure,
    'group'      => $group,
    'alerts'     => $alerts,
    'noalerts'   => $noalerts,
    'depends'    => $depends,
    'priority'   => $priority,
    'bundle'     => $bundle,
  }

  $check_name_initd = "${check_name}_initd"
  $check_name_binary = "${check_name}_binary"

  # Check service process.
  $depends_all = union($depends, [$check_name_initd, $check_name_binary])
  $params_process = {
    'check_name'      => $check_name,
    'depends'         => $depends_all,
    'tests'           => $tests,
    'pidfile'         => $pidfile,
    'uid'             => $uid,
    'gid'             => $gid,
    'program_start'   => $program_start,
    'program_stop'    => $program_stop,
    'program_restart' => $program_restart,
    'bundle'          => $bundle,
    'order'           => $order,
    'timeout'         => $timeout,
    'timeout_start'   => $timeout_start,
    'timeout_stop'    => $timeout_stop,
    'timeout_restart' => $timeout_restart,
  }
  ensure_resource("monit::check::process", "${check_name}_process", merge($defaults, $params_process))

  # Check service initd.
  $params_initd = {
    'check_name' => $check_name_initd,
    'path'       => $initd,
    'bundle'     => $bundle,
    'order'      => inline_template("<%= @order.to_i + 1 %>"),
  }
  ensure_resource("monit::check::file", "$check_name_initd", merge($defaults, $params_initd))

  # Check service binary.
  $params_binary = {
    'check_name' => $check_name_binary,
    'path'       => $binary,
    'bundle'     => $bundle,
    'order'      => inline_template("<%= @order.to_i + 2 %>"),
  }
  ensure_resource("monit::check::file", $check_name_binary, merge($defaults, $params_binary))
}

