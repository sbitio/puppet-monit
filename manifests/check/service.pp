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
    'check_name'    => $check_name,
    'depends'       => $depends_all,
    'tests'         => $tests,
    'pidfile'       => $pidfile,
    'start_program' => $start_program,
    'stop_program'  => $stop_program,
    'bundle'        => $bundle,
    'order'         => $order,
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

