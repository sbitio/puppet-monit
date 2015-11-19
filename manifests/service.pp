class monit::service {

  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  #Debian Squeeze's monit package isn't configured to auto-start out of the box
  if $::operatingsystem == "Debian" and versioncmp($::lsbmajdistrelease, "6") == 0 {
    augeas { "monit_defaults":
      context => "/files/etc/default/monit",
      onlyif  => "get /files/etc/default/monit/startup != '1'",
      changes => "set /files/etc/default/monit/startup 1",
      notify  => Service[$monit::service],
    }
  }

  service { $monit::service:
    ensure => $monit::service_ensure,
    enable => $monit::service_enable,
  }
}

