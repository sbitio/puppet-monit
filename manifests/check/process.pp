# == Defined type: monit::check::process
#
# Implement Monit's CHECK PROCESS
#
define monit::check::process(
  # Check type specific.
  $program_start,
  $program_stop,
  $template        = 'monit/check/process.erb',
  $pidfile         = undef,
  $matching        = undef,
  $uid             = undef,
  $gid             = undef,
  $timeout         = undef,
  $timeout_start   = undef,
  $timeout_stop    = undef,

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

  if $pidfile {
    validate_absolute_path($pidfile)
    if $matching {
      warning("monit::check::process: both 'pidfile' and 'matching' provided. Ignoring 'matching'.")
    }
  }
  elsif !$matching {
    fail("monit::check::process: no parameter 'pidfile' nor 'matching' provided. You must provide one of both.")
  }

  if $timeout {
    $real_timeout_start   = pick($timeout_start, $timeout)
    $real_timeout_stop    = pick($timeout_stop, $timeout)
  }

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    name     => $name,
    type     => 'process',
    header   => template($template),
    group    => $group,
    alerts   => $alerts,
    noalerts => $noalerts,
    tests    => $tests,
    depends  => $depends,
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
  }
}

