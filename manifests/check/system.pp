define monit::check::system(
  $ensure,
  $group,
  $priority,
  $alert,
  $tests
) {

  $filename = "${monit::conf_dir}/${priority}_${group}"
  $content = template('monit/check_system.erb')

  monit::check::instance { "${name}_instance":
    ensure  => $ensure,
    file    => $filename,
    content => $content,
  }
}
