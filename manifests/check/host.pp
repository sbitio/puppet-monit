# == Defined type: monit::check::host
#
# Implement Monit's CHECK HOST
#
define monit::check::host(
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
  String $template = 'monit/check/host.erb',
  String $address
) {

  #@todo@ match regex for hostname and ip address
  #Could leverage thrnio/puppet-ip
  # Any solution is overkill as of today.
  #if !is_domain_name($address) and !is_ip_address($address) {
  # fail("Invalid domain name or ip address '${address}'.")
  #}

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    name     => $name,
    type     => 'host',
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

