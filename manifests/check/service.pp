define monit::check::service(
  # Common parameters.
  $ensure        = present,
  $check_name    = $name,
  $group         = $name,
  $alerts        = [],
  $tests         = [],
  $priority      = '',
  $bundle        = $name,
  $order         = 0,
  $template      = undef,

  # Check type specific.
  $service       = $check_name,
  $pidfile       = "/var/run/${service}",
  $binary        = "/usr/sbin/${service}",
  $initd         = "/etc/init.d/${service}",
  $start_program = "${initd} start",
  $stop_program  = "${initd} stop"
) {
  validate_absolute_path($pidfile)
  validate_absolute_path($binary)
  validate_absolute_path($initd)

  $defaults = {
    'ensure'     => $ensure,
    'check_name' => $check_name,
    'group'      => $group,
    'alerts'     => $alerts,
    'priority'   => $priority,
    'bundle'     => $bundle,
  }

  # Check service process.
  $params_process = {
    'tests'         => $tests,
    'pidfile'       => $pidfile,
    'start_program' => $start_program,
    'stop_program'  => $stop_program,
    'bundle'        => $bundle,
    'order'         => $order,
  }
  ensure_resource("monit::check::process", "${name}_process", merge($defaults, $params_process))

  # Check service initd.
  $params_initd = {
    'path'   => $initd,
    'bundle' => $bundle,
    'order'  => inline_template("<%= @order.to_i + 1 %>"),
  }
  ensure_resource("monit::check::file", "${name}_initd", merge($defaults, $params_initd))

  # Check service binary.
  $params_binary = {
    'path'   => $binary,
    'bundle' => $bundle,
    'order'  => inline_template("<%= @order.to_i + 2 %>"),
  }
  ensure_resource("monit::check::file", "${name}_binary", merge($defaults, $params_binary))

  # TODO: Check any other provided.
}

