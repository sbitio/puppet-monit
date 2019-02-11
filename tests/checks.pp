include '::monit'

monit::check { 'check':
  type => 'system',
}
monit::check::instance { 'instance':
  ensure   => 'present',
  type     => 'system',
  header   => '',
  group    => '',
  alerts   => [],
  noalerts => [],
  tests    => [],
  depends  => [],
  priority => '10',
  bundle   => '',
  order    => 0,
}

monit::check::directory { 'directory':
  path => '/path/to/directory',
}
monit::check::fifo { 'fifo':
  path => '/path/to/fifo',
}
monit::check::file { 'file':
  path  => '/path/to/file',
}
monit::check::filesystem { '/':
  path  => '/',
  tests => [
    {'type' => 'fsflags'},
    {'type' => 'permission', 'value' => '0755'},
    {'type' => 'space', 'operator' => '>', 'value' => '80%'},
  ]
}
monit::check::host { 'localhost':
  address => '127.0.0.1',
}
monit::check::process { 'daemon':
  program_start => '/etc/init.d/daemon start',
  program_stop  => '/etc/init.d/daemon stop',
  pidfile       => '/var/run/daemon.pid',
}
monit::check::program { 'exe':
  path => '/path/to/executable arg1 arg2',
}
monit::check::service { 'srv':
  matching => 'srv',
}
monit::check::system { 'system':
}
