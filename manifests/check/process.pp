# monit::check::process
#
# Implement Monit's CHECK PROCESS
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
# @param program_start String Command to start the service.
# @param program_stop String Command to stop the service.
# @param pidfile Stdlib::Absolutepath Path to the PID file of the service.
# @param matching String If the service doesn't provide a PID file, use this option to pass a regex pattern to check the process list.
# @param uid Integer UID of the process.
# @param gid Integer GID of the process.
# @param timeout Numeric Timeout on the start/stop operations.
# @param timeout_start Numeric Timeout on the start operation. Generic timeout will be used if not specified.
# @param timeout_stop Numeric Timeout on the stop operation. Generic timeout will be used if not specified.
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
    Hash[String, Variant[Array, Hash, Integer, String]]
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

