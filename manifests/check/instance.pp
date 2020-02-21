# monit::check::instance
# @api private
#
# Common code invoked by all check types.
# Creates Monit check files by fragments.
#
#
# @param ensure
#   Whether this check must be present or absent.
# @param type
#   Type of check.
# @param header
#   Fragment of the test specific config.
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
define monit::check::instance(
  Enum[
    'present',
    'absent'
    ] $ensure,
  String $type,
  String $header,
  String $group,
  Array[String] $alerts,
  Array[String] $noalerts,
  Array[
    Hash[String, Variant[Array, Hash, Integer, String]]
    ] $tests,
  Array[String] $depends,
  String $priority,
  String $bundle,
  Integer $order,
  Optional[Hash] $restart_limit = undef,
) {

  if $restart_limit {
    if !has_key($restart_limit, 'restarts') or !has_key($restart_limit, 'cycles') or !has_key($restart_limit, 'action') {
      fail("monit::check::process: please ensure 'restart' parameter contains 'restarts', 'cycles' and 'action'.")
    } else {
      $restarts = $restart_limit['restarts']
      $cycles = $restart_limit['cycles']
      $action = $restart_limit['action']
    }
  }

  $priority_real = $priority ? {
    undef   => '',
    default => "${priority}_",
  }
  $file = "${monit::conf_dir}/${priority_real}${bundle}"
  if !defined(Concat[$file]) {
    concat{ $file:
      ensure         => $ensure,
      warn           => true,
      ensure_newline => true,
      notify         => Service[$monit::service],
    }
  }

  $tests_real = monit_validate_tests($type, $tests)
  $content = template('monit/check/common.erb')
  concat::fragment { "${file}_${name}":
    target  => $file,
    content => "${header}${content}",
    # Add one to the order, since the warn message above has order 0
    order   => Integer(inline_template('<%= @order.to_i + 1 %>')),
  }
}

