# monit::check::filesystem
#
# Implement Monit's CHECK FILESYSTEM
#
#
# @param ensure Enum['present', 'absent'] Whether this check must be present or absent.
# @param group String Monit group.
# @param alerts Array[String] Alert recipients (with event filters) to set.
# @param noalerts Array[String] Alerts to disable for this check.
# @param tests Array[Hash[String, Variant[Array, Hash, Integer, String]]] Monit tests.
# @param depends Array[String] Dependencies of this check on other checks.
# @param priority String Used as a prefix for the filename generated. Load order doesn't matter to Monit. This is just a facility to organize your checks by filename.
# @param bundle String Used to group checks by filename. All checks in the same bundle will be added to the same filename.
# @param order Integer Order of the check within the bundle filename.
# @param template String Template used to generate the check file.
# @param path Optional[Variant[Stdlib::Absolutepath, Pattern['^/']]] Path of the filesystem to check (**Deprecated**. Use $paths).
# @param paths Variant[Array[Stdlib::Absolutepath], Array[Pattern['^/']]] List of paths of filesystems to check. If empty, will check all mounted filesystems, but the ones with a type in $monit::banned_fs_types.
#
define monit::check::filesystem(
  # Common parameters.
  Enum[
    'present',
    'absent'
    ] $ensure             = present,
  String $group           = $name,
  Array[String] $alerts   = [],
  Array[String] $noalerts = [],
  Array[
    Hash[String, Variant[Array, Hash, Integer, String]]
    ] $tests              = [],
  Array[String] $depends  = [],
  String $priority        = '20',
  String $bundle          = $name,
  Integer $order          = 0,

  # Check type specific.
  String $template        = 'monit/check/filesystem.erb',
  Optional[Variant[
    Stdlib::Absolutepath,
    Pattern['^/']
  ]] $path                = undef,
  Variant[
    Array[Stdlib::Absolutepath],
    Array[Pattern['^/']]
    ] $paths              = [],
) {

  if !empty($path) {
    notice('\$path parameter is deprecated and will be removed in future versions! Please use \$paths instead')
    $_paths = $paths + $path
  }
  else {
    $_paths = $paths
  }

  if empty($_paths) {
    $paths_real = keys($::mountpoints.filter |$key, $value| { !($value['filesystem'] in $monit::fs_banned_types) })
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

