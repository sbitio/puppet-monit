define monit::check::instance(
  $ensure,
  $file,
  $content,
  $order = 1,
) {
  if !defined(Concat[$file]) {
    concat{ $file:
      ensure => $ensure,
    }
    concat::fragment { "${file}-header":
      ensure  => $ensure,
      target  => $file,
      content => "#MANAGED BY PUPPET!\n\n",
      order   => 0,
    }
  }
  concat::fragment { "${file}-${name}":
    ensure  => $ensure,
    target  => $file,
    content => $content,
    order   => $order,
  }
}

