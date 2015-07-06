# == Defined type: monit::check::file
#
# Implement Monit's CHECK FILE
#
define monit::check::file(
  # Check type specific.
  $path,
  $template   = 'monit/check/file.erb',

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
    ensure   => $ensure,
    name     => $name,
    type     => 'file',
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
    template => $template,
    tests    => $tests,
  }
}

