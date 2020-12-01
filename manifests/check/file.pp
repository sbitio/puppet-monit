# monit::check::file
#
# Implement Monit's CHECK FILE
#
#
# @param path
#   Path to the file to check.
# @param template
#   Template used to generate the check file.
# @param ensure
#   Whether this check must be present or absent.
# @param group
#   Monit group.
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
# @param restart_limit
#   Used to define limits on restarts.
#
define monit::check::file(
  # Check type specific.
  Stdlib::Absolutepath $path,
  String $template             = 'monit/check/file.erb',

  # Common parameters.
  Monit::Check::Ensure $ensure = 'present',
  String $group                = $name,
  Array[String] $alerts        = [],
  Array[String] $noalerts      = [],
  Monit::Check::Tests $tests   = [],
  Array[String] $depends       = [],
  String $priority             = '20',
  String $bundle               = $name,
  Integer $order               = 0,
  Optional[Monit::RestartLimit] $restart_limit = undef,
) {

  monit::check::instance { "${name}_instance":
    ensure            => $ensure,
    name              => $name,
    type              => 'file',
    header            => template($template),
    group             => $group,
    alerts            => $alerts,
    noalerts          => $noalerts,
    tests             => $tests,
    depends           => $depends,
    priority          => $priority,
    bundle            => $bundle,
    order             => $order,
    restart_limit     => $restart_limit,
  }
}
