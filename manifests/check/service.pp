define monit::check::service(
  # Common parameters.
  $ensure        = present,
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
  $service         = $name,
  $pidfile,
  $binary          = "/usr/sbin/${name}",
  $initd           = "/etc/init.d/${name}",

  # Params for process type.
  $uid             = undef,
  $gid             = undef,
  $program_start   = "/etc/init.d/${name} start",
  $program_stop    = "/etc/init.d/${name} stop",
  $program_restart = "/etc/init.d/${name} restart",
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

  # Check service process.
  $depends_all = union($depends, ["${name}_initd", "${name}_binary"])
  $params_process = {
    'name'            => $name,
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
  ensure_resource("monit::check::process", "${name}_process", merge($defaults, $params_process))

  # Check service initd.
  $params_initd = {
    'path'       => $initd,
    'bundle'     => $bundle,
    'order'      => inline_template("<%= @order.to_i + 1 %>"),
  }
  ensure_resource("monit::check::file", "${name}_initd", merge($defaults, $params_initd))

  # Check service binary.
  $params_binary = {
    'path'       => $binary,
    'bundle'     => $bundle,
    'order'      => inline_template("<%= @order.to_i + 2 %>"),
  }
  ensure_resource("monit::check::file", "${name}_binary", merge($defaults, $params_binary))
}

