# == Defined type: monit::check::program
#
# Implement Monit's CHECK PROGRAM
#
define monit::check::program(
  # Check type specific.
  $path,
  $template   = 'monit/check/program.erb',

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

  $path_parts = split($path, ' ')
  validate_absolute_path($path_parts[0])

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    name     => $name,
    type     => 'program',
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

