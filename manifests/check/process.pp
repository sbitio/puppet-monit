# monit::check::process
#
# Implement Monit's CHECK PROCESS
#
#
# @param program_start
#   Command to start the service.
# @param program_stop
#   Command to stop the service.
# @param template
#   Template used to generate the check file.
# @param pidfile
#   Path to the PID file of the service.
# @param matching
#   If the service doesn't provide a PID file, use this option to pass a regex pattern to check the process list.
# @param uid
#   UID of the process.
# @param gid
#   GID of the process.
# @param timeout
#   Timeout on the start/stop operations.
# @param timeout_start
#   Timeout on the start operation. Generic timeout will be used if not specified.
# @param timeout_stop
#   Timeout on the stop operation. Generic timeout will be used if not specified.
# @param restart_limit
#   Used to define limits on restarts.
# @param ensure
#   Whether this check must be present or absent.
# @param group
#   Monit group.
# @param every
#   Service poll time.
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
define monit::check::process (
  # Check type specific.
  Optional[String] $program_start         = undef,
  Optional[String] $program_stop          = undef,
  String $template                        = 'monit/check/process.erb',
  Optional[Stdlib::Absolutepath] $pidfile = undef,
  Optional[String] $matching              = undef,
  Optional[Integer] $uid                  = undef,
  Optional[Integer] $gid                  = undef,
  Optional[Numeric] $timeout              = undef,
  Optional[Numeric] $timeout_start        = undef,
  Optional[Numeric] $timeout_stop         = undef,

  # Common parameters.
  Monit::Check::Ensure $ensure            = 'present',
  String $group                           = $name,
  Optional[String] $every                 = undef,
  Array[String] $alerts                   = [],
  Array[String] $noalerts                 = [],
  Monit::Check::Tests $tests              = [],
  Array[String] $depends                  = [],
  String $priority                        = '20',
  String $bundle                          = $name,
  Integer $order                          = 0,
  Optional[Hash] $restart_limit           = undef,
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
    ensure        => $ensure,
    name          => $name,
    type          => 'process',
    header        => template($template),
    group         => $group,
    every         => $every,
    alerts        => $alerts,
    noalerts      => $noalerts,
    tests         => $tests,
    depends       => $depends,
    priority      => $priority,
    bundle        => $bundle,
    order         => $order,
    restart_limit => $restart_limit,
  }
}
