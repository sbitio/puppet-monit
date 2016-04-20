# == Defined type: monit::check::instance
#
# Common code invoked by all check types.
# Creates Monit check files by fragments.
#
define monit::check::instance(
  $ensure,
  $type,
  $header,
  $group,
  $alerts,
  $noalerts,
  $tests,
  $depends,
  $priority,
  $bundle,
  $order,
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

