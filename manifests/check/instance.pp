define monit::check::instance(
  $ensure,
  $type,
  $priority,
  $bundle,
  $order,
  $template,
  $tests,
) {

  # TODO: Check empty
  $priority_real = "${priority}_"
  $file = "${monit::conf_dir}/${priority}${bundle}"
  if !defined(Concat[$file]) {
    concat{ $file:
      ensure         => $ensure,
      warn           => "# MANAGED BY PUPPET!\n\n",
      ensure_newline => true,
    }
  }

  #$tests_real = monit_parse_tests($type, $tests)
  $tests_real = monit_validate_tests($type, $tests)
  concat::fragment { "${file}_${name}":
    ensure  => $ensure,
    target  => $file,
    content => template($template, 'monit/check/common.erb'),
    order   => $order,
  }
}

