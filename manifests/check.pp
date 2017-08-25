# == Defined type: monit::check
#
# This define is a facility used as entry point for tests defined in Hiera.
# See main class for reference.
#
# === Parameters
#
# [*type*]
#   Type of check to perform. It supports all the primitive check types
#   supported by Monit and the 'service' compound check type.
#
# [*config*]
#   Hash of parameters for `monit::check::${type}`. Empty parameters
#   will be given the default values.
#
# [*group*]
#   Monit group.
#
# [*alerts*]
#   Array of Monit alerts.
#
# [*tests*]
#   Hash of Monit tests.
#
# [*priority*]
#   Used as a prefix for the filename generated. Load order doesn't matter
#   to Monit. This is just a facility to organize your checks by filename.
#
# [*bundle*]
#   Used to group checks by filename. All checks in the same bundle will
#   be added to the same filename.
#
# [*order*]
#   Order of the check within the bundle filename.
#
define monit::check(
  Enum[
    'present',
    'absent'
    ] $ensure                  = 'present',
  Hash[String, String] $config = {},
  String $group                = $name,
  Array[
    Hash[String, String]
    ] $tests                   = [],
  String $priority             = '20',
  String $template             = "monit/check/${type}.erb",
  String $bundle               = $name,
  Integer $order               = 0,
  Enum[
    'directory',
    'fifo',
    'file',
    'filesystem',
    'host',
    'process',
    'program',
    'service',
    'system'
    ] $type,
) {

  $defaults = {
    'name'       => $name,
    'ensure'     => $ensure,
    'group'      => $group,
    'tests'      => $tests,
    'priority'   => $priority,
    'bundle'     => $bundle,
    'order'      => $order,
  }
  $params = merge($config, $defaults)
  ensure_resource("monit::check::${type}", "${name}_${type}", $params)
}

