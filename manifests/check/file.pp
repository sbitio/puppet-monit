define monit::check::file(
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
  $content = template('monit/check/file.erb')

  monit::check::instance { "${name}_instance":
    ensure  => $ensure,
    file    => $filename,
    content => $content,
  }
}

