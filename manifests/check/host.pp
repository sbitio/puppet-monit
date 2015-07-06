# == Defined type: monit::check::host
#
# Implement Monit's CHECK HOST
#
define monit::check::host(
  # Check type specific.
  $address,
  $template   = 'monit/check/host.erb',

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
  if !is_domain_name($address) or !is_ip_address($address) {
    fail("Invalid domain name or ip address '${address}'.")
  }

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    name     => $name,
    type     => 'host',
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
    template => $template,
    tests    => $tests,
  }
}

