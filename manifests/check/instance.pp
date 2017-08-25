# == Defined type: monit::check::instance
#
# Common code invoked by all check types.
# Creates Monit check files by fragments.
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
    Hash[String, String]
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
      warn           => "# MANAGED BY PUPPET!\n\n",
      ensure_newline => true,
    }
  }

  $tests_real = monit_validate_tests($type, $tests)
  $content = template('monit/check/common.erb')
  concat::fragment { "${file}_${name}":
    target  => $file,
    content => "${header}${content}",
    order   => $order,
    notify  => Service[$monit::service],
  }
}

