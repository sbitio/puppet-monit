define monit::check(
  $ensure = present,
  $type,
  $group    = $name,
  $priority = 20,
  $alert    = [],
  $config   = {},
  $tests    = [],
) {
  validate_hash($config)
  validate_array($tests)

  $tests_real = monit_validate_tests($type, $tests)

  $defaults = {
    'ensure'     => $ensure,
    'priority'   => $priority,
    'check_name' => $name,
    'group'      => $group,
    'alert'      => $alert,
    'tests'      => $tests_real,
  }
  $params = merge($config, $defaults)
  ensure_resource("monit::check::${type}", "${type}_${name}", $params)
}

