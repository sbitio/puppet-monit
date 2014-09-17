define monit::check::process(
  # Common parameters.
  $ensure     = present,
  $group      = $name,
  $alerts     = [],
  $noalerts   = [],
  $tests      = [],
  $depends    = [],
  $priority   = '',
  $bundle     = $name,
  $order      = 0,

  # Check type specific.
  $template        = "monit/check/process.erb",
  $pidfile,
  $uid             = undef,
  $gid             = undef,
  $program_start,
  $program_stop,
  $program_restart = undef,
  $timeout         = undef,
  $timeout_start   = $timeout,
  $timeout_stop    = $timeout,
  $timeout_restart = $timeout,
) {
  validate_absolute_path($pidfile)

  monit::check::instance { "${name}_instance":
    name     => $name,
    ensure   => $ensure,
    type     => 'process',
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
    template => $template,
    tests    => $tests,
  }
}

