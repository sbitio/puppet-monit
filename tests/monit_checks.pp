class { '::monit':
  checks => {
    'sshd' => {
      'type'    => 'service',
      'config' => {
        'pidfile'       => '/var/run/sshd.pid',
        'program_start' => '/etc/init.d/sshd start',
        'program_stop'  => '/etc/init.d/sshd stop',
      },
      'tests'  => [
        {
          'type'     => 'connection',
          'host'     => '127.0.0.1',
          'port'     => '22',
          'protocol' => 'ssh',
          'action'   => 'restart',
        },
      ],
    },
  }
}
