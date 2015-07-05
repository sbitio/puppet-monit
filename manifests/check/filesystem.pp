define monit::check::filesystem(
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

  # Check type specific.
  $template   = 'monit/check/filesystem.erb',
  $path
) {
  validate_absolute_path($path)

  monit::check::instance { "${name}_instance":
    name     => $name,
    ensure   => $ensure,
    type     => 'filesystem',
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
    template => $template,
    tests    => $tests,
  }
}

