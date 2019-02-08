# == Defined type: monit::check::process
#
# Implement Monit's CHECK PROCESS
#
define monit::check::process(
  # Check type specific.
  $program_start,
  $program_stop,
  $template          = 'monit/check/process.erb',
  $pidfile           = undef,
  $matching          = undef,
  $uid               = undef,
  $gid               = undef,
  $timeout           = undef,
  $timeout_start     = undef,
  $timeout_stop      = undef,
  $restart_tolerance = undef,

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

  if $restart_tolerance {
    if !has_key($restart_tolerance, 'restarts') or !has_key($restart_tolerance, 'cycles') or !has_key($restart_tolerance, 'action') {
      fail("monit::check::process: please ensure 'restart' parameter contains 'restarts', 'cycles' and 'action'.")
    } else {
      $restarts = $restart_tolerance['restarts']
      $cycles = $restart_tolerance['cycles']
      $action = $restart_tolerance['action']
    }
  }
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

