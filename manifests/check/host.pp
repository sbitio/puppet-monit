define monit::check::host(
  # Common parameters.
  $ensure     = present,
  $check_name = $name,
  $group      = $name,
  $alerts     = [],
  $noalerts   = [],
  $tests      = [],
  $priority   = '',
  $bundle     = $name,
  $order      = 0,

  # Check type specific.
  $template   = "monit/check/host.erb",
  $address
) {
  validate_absolute_path($path)

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    type     => 'host',
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
    template => $template,
    tests    => $tests,
  }
}

