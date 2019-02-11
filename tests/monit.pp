class { '::monit':
  check_interval    => 60,
  check_start_delay => 120,
  mailserver        => 'localhost',
  eventqueue        => true,
  alerts            => ['root@localhost', 'sla1@example.com only on { timeout, nonexist }'],
  httpserver        => true,
  httpserver_allow  => ['admin:secret'],
}
