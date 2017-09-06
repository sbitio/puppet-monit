# == Defined type: monit::check::fifo
#
# Implement Monit's CHECK FIFO
#
define monit::check::fifo(
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
  String $template           = 'monit/check/fifo.erb',
  Stdlib::Absolutepath $path
) {

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    name     => $name,
    type     => 'fifo',
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

