# == Defined type: monit::check::process
#
# Implement Monit's CHECK PROCESS
#
define monit::check::process(
  # Common parameters.
  Enum[
    'present',
    'absent'
    ] $ensure             = present,
  String $group           = $name,
  Array[String] $alerts   = [],
  Array[String] $noalerts = [],
  Array[
    Hash[String, String]
    ] $tests              = [],
  Array[String] $depends  = [],
  String $priority        = '20',
  String $bundle          = $name,
  Integer $order          = 0,

  # Check type specific.
  String $template                        = 'monit/check/process.erb',
  String $program_start,
  String $program_stop,
  Optional[Stdlib::Absolutepath] $pidfile = undef,
  Optional[String] $matching              = undef,
  Optional[Integer] $uid                  = undef,
  Optional[Integer] $gid                  = undef,
  Optional[Numeric] $timeout              = undef,
  Optional[Numeric] $timeout_start        = undef,
  Optional[Numeric] $timeout_stop         = undef,
) {

  if $pidfile {
    if $matching {
      warning("monit::check::process: both 'pidfile' and 'matching' provided. Ignoring 'matching'.")
    }
  }
  elsif !$matching {
    fail("monit::check::process: no parameter 'pidfile' nor 'matching' provided. You must provide one of both.")
  }

  if $timeout {
    $real_timeout_start = pick($timeout_start, $timeout)
    $real_timeout_stop  = pick($timeout_stop, $timeout)
  }

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    name     => $name,
    type     => 'process',
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

