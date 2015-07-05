define monit::check::host(
  # Check type specific.
  $address,
  $template   = 'monit/check/host.erb',

  # Common parameters.
  $ensure     = present,
  $group      = $name,
  $alerts     = [],
  $noalerts   = [],
  $tests      = [],
  $depends    = [],
  $priority   = '20',
  $bundle     = $name,
  $order      = 0,
) {
  validate_absolute_path($path)

  monit::check::instance { "${name}_instance":
    name     => $name,
    ensure   => $ensure,
    type     => 'host',
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
    template => $template,
    tests    => $tests,
  }
}

