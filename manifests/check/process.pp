define monit::check::process(
  $ensure,
  $check_name,
  $group,
  $priority,
  $alert,
  $tests,
  $pidfile,
  $start_program,
  $stop_program
) {
  validate_absolute_path($pidfile)

  $filename = "${monit::conf_dir}/${priority}_${group}"
  $content = template('monit/check/process.erb')

  monit::check::instance { "${name}_instance":
    ensure  => $ensure,
    file    => $filename,
    content => $content,
  }
}

