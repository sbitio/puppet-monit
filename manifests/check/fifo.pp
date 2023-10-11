# monit::check::fifo
#
# Implement Monit's CHECK FIFO
#
#
# @param path
#   Path to the fifo to check.
# @param template
#   Template used to generate the check file.
# @param ensure
#   Whether this check must be present or absent.
# @param group
#   Monit group.
# @param every
#   Service poll time.
# @param alerts
#   Alert recipients (with event filters) to set.
# @param noalerts
#   Alerts to disable for this check.
# @param tests
#   Monit tests.
# @param depends
#   Dependencies of this check on other checks.
# @param priority
#   Used as a prefix for the filename generated. Load order doesn't matter to Monit.
#   This is just a facility to organize your checks by filename.
# @param bundle
#   Used to group checks by filename. All checks in the same bundle will be added to the same filename.
# @param order
#   Order of the check within the bundle filename.
#
define monit::check::fifo(
  # Check type specific.
  Stdlib::Absolutepath $path,
  String $template             = 'monit/check/fifo.erb',

  # Common parameters.
  Monit::Check::Ensure $ensure = 'present',
  String $group                = $name,
  String $every                = '',
  Array[String] $alerts        = [],
  Array[String] $noalerts      = [],
  Monit::Check::Tests $tests   = [],
  Array[String] $depends       = [],
  String $priority             = '20',
  String $bundle               = $name,
  Integer $order               = 0,
) {

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    name     => $name,
    type     => 'fifo',
    header   => template($template),
    group    => $group,
    every    => $every,
    alerts   => $alerts,
    noalerts => $noalerts,
    tests    => $tests,
    depends  => $depends,
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
  }
}
