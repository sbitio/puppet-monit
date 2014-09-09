define monit::check::fifo(
  $ensure,
  $check_name,
  $group,
  $priority,
  $alert,
  $tests,
  $path
) {
  validate_absolute_path($path)

  $filename = "${monit::conf_dir}/${priority}_${group}"
  $content = template('monit/check/fifo.erb')

  monit::check::instance { "${name}_instance":
    ensure  => $ensure,
    file    => $filename,
    content => $content,
  }
}

