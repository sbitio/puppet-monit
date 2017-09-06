# monit::check
#
# This define is a facility used as entry point for tests defined in Hiera.
# See main class for reference.
#
#
# @param ensure Enum['present', 'absent'] Whether this check must be present or absent.
# @param config Hash[String, String] Parameters for `monit::check::${type}`. Empty parameters will be given the default values.
# @param group String Monit group.
# @param tests Array[Hash[String, Variant[Array, Hash, Integer, String]]] Monit tests.
# @param priority String Used as a prefix for the filename generated. Load order doesn't matter to Monit. This is just a facility to organize your checks by filename.
# @param template String Template used to generate the check file.
# @param bundle String Used to group checks by filename. All checks in the same bundle will be added to the same filename.
# @param order Integer Order of the check within the bundle filename.
# @param type Enum['directory', 'fifo', 'file', 'filesystem', 'host', 'process', 'program', 'service', 'system'] Type of check to perform. See `manifests/check/*.pp` for details.
#
define monit::check(
  Enum[
    'present',
    'absent'
    ] $ensure                  = 'present',
  Hash[String, String] $config = {},
  String $group                = $name,
  Array[
    Hash[String, Variant[Array, Hash, Integer, String]]
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

