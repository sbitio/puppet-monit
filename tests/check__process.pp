include '::monit'

monit::check { 'ntp':
  type              => 'process',
  config            => {
    'pidfile'       => '/var/run/ntpd.pid',
    'program_start' => '/etc/init.d/ntp start',
    'program_stop'  => '/etc/init.d/ntp stop',
  },
  tests             => [
    {
      'type'     => 'connection',
      'host'     => '127.0.0.1',
      'port'     => '123',
      'protocol' => 'ntp',
      'action'   => 'restart',
    },
  ],
}
