# monit::check::filesystem
#
# Implement Monit's CHECK FILESYSTEM
#
#
# @param template
#   Template used to generate the check file.
# @param path
#   Path of the filesystem to check (**Deprecated**. Use $paths).
# @param paths
#   List of paths of filesystems to check. If empty, will check all mounted filesystems,
#   but the ones with a type in $monit::banned_fs_types.
# @param ensure
#   Whether this check must be present or absent.
# @param group
#   Monit group.
# @param every
#   Service poll time
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
define monit::check::filesystem(
  # Check type specific.
  String $template             = 'monit/check/filesystem.erb',
  Optional[Variant[
    Stdlib::Absolutepath,
    Pattern['^/']
  ]] $path                     = undef,
  Variant[
    Array[Stdlib::Absolutepath],
    Array[Pattern['^/']]
    ] $paths                   = [],

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

  if !empty($path) {
    warning('\$path parameter is deprecated and will be removed in future versions! Please use \$paths instead')
    $_paths = $paths + $path
  }
  else {
    $_paths = $paths
  }

  if empty($_paths) {
    $paths_real = keys($::facts['mountpoints'].filter |$key, $value| { !($value['filesystem'] in $monit::fs_banned_types) })
  }
  else {
    $paths_real = $_paths
  }
  $paths_real.each |$path| {
    monit::check::instance { "${name}_${path}_instance":
      ensure   => $ensure,
      name     => "${name}_${path}",
      type     => 'filesystem',
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
}
