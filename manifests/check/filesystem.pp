# == Defined type: monit::check::filesystem
#
# Implement Monit's CHECK FILESYSTEM
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
  Variant[
    Stdlib::Absolutepath,
    Pattern['^/']
    ] $path,
) {

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    name     => $name,
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

