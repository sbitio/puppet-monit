define monit::check::file(
  # Common parameters.
  $ensure     = present,
  $check_name = $name,
  $group      = $name,
  $alerts     = [],
  $tests      = [],
  $priority   = '',
  $bundle     = $name,
  $order      = 0,

  # Check type specific.
  $template   = "monit/check/file.erb",
  $path
) {
  validate_absolute_path($path)

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    type     => 'file',
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
    template => $template,
    tests    => $tests,
  }
}

