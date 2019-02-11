# monit::config
# @api private
#
# This class handles monit package.
#
class monit::install {

  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  package { $monit::package:
    ensure => present,
  }
}

