# monit::check::host
#
# Implement Monit's CHECK HOST
#
#
# @param address
#   Hostname or ip address of the host to check.
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
#
define monit::check::host(
  # Check type specific.
  String $address,
  String $template = 'monit/check/host.erb',

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

