define monit::check::system(
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
  $template   = "monit/check/system.erb",
) {

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    type     => 'system',
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
    template => $template,
    tests    => $tests,
  }
}

