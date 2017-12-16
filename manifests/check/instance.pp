# monit::check::instance
# @api private
#
# Common code invoked by all check types.
# Creates Monit check files by fragments.
#
#
# @param ensure Enum['present', 'absent'] Whether this check must be present or absent.
# @param type String Type of check.
# @param header String Fragment of the test specific config.
# @param group String Monit group.
# @param alerts Array[String] Alert recipients (with event filters) to set.
# @param noalerts Array[String] Alerts to disable for this check.
# @param tests Array[Hash[String, Variant[Array, Hash, Integer, String]]] Monit tests.
# @param depends Array[String] Dependencies of this check on other checks.
# @param priority String Used as a prefix for the filename generated. Load order doesn't matter to Monit. This is just a facility to organize your checks by filename.
# @param bundle String Used to group checks by filename. All checks in the same bundle will be added to the same filename.
# @param order Integer Order of the check within the bundle filename.
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
) {

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
    }
  }

  $tests_real = monit_validate_tests($type, $tests)
  $content = template('monit/check/common.erb')
  concat::fragment { "${file}_${name}":
    target  => $file,
    content => "${header}${content}",
    # Add one to the order, since the warn message above has order 0
    order   => 0 + inline_template('<%= @order.to_i + 1 %>'),
    notify  => Service[$monit::service],
  }
}

