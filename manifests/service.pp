# monit::config
# @api private
#
# This class handles the monit service.
#
class monit::service {

  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  service { $monit::service:
    ensure => $monit::service_ensure,
    enable => $monit::service_enable,
  }
}

