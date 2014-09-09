define monit::check::host(
  $ensure,
  $check_name,
  $group,
  $priority,
  $alert,
  $tests,
  $address
) {
  validate_absolute_path($path)

  $filename = "${monit::conf_dir}/${priority}_${group}"
  $content = template('monit/check/host.erb')

  monit::check::instance { "${name}_instance":
    ensure  => $ensure,
    file    => $filename,
    content => $content,
  }
}

