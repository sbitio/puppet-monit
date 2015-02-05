Puppet Monit
============

Performs installation and configuration of Monit service.

Hiera examples
--------------

```yaml
monit::check_interval    : 60
monit::check_start_delay : 120
monit::mailserver        : localhost
monit::eventqueue        : true
monit::alert             :
  - root@localhost
monit::httpserver        : true
monit::httpserver_allow  :
  - admin:secret

monit::checks :
  "%{::hostname}" :
    type          : system
    tests         :
      - type      : 'loadavg(1min)'
        operator  : '>'
        value     : 6
      - type      : 'loadavg(5min)'
        operator  : '>'
        value     : 3
      - type      : 'cpu(user)'
        operator  : '>'
        value     : 80%
      - type      : 'cpu(system)'
        operator  : '>'
        value     : 30%
      - type      : 'cpu(wait)'
        operator  : '>'
        value     : 30%
      - type      : 'memory'
        operator  : '>'
        value     : 75%

  rootfs :
    type     : filesystem
    config   :
      path   : /
    tests    :
      - type: fsflags
      - type: permission
        value: '0755'
      - type: space
        operator: '>'
        value: 80%

  sshd :
    type    : process
    config  :
      pidfile       : "/var/run/sshd.pid"
      start_program : "/etc/init.d/sshd start"
      stop_program  : "/etc/init.d/sshd stop"
    tests  :
      - type     : connection
        host     : 127.0.0.1
        port     : 22
        protocol : ssh
        action   : restart

  php5-fpm :
    type    : process
    config  :
      pidfile       : "/var/run/php5-fpm.pid"
      binary        : "/usr/sbin/php5-fpm"
      start_program : "/etc/init.d/php5-fpm start"
      stop_program  : "/etc/init.d/php5-fpm stop"
    tests  :
      - type          : 'connection'
        host          : '127.0.0.1'
        port          : 9000
        socket_type   : 'TCP'
        protocol      : 'GENERIC'
        protocol_test :
          - send   : '"\0x01\0x09\0x00\0x00\0x00\0x00\0x08\0x00\0x00\0x00\0x00\0x00\0x00\0x00\0x00\0x00"'
            expect : '"\0x01\0x0A"'
        action   : restart


  ntp:
    type: process
    config:
      pidfile: "/var/run/ntpd.pid"
      start_program: "/etc/init.d/ntpd start"
      stop_program: "/etc/init.d/ntpd stop"
    tests:
      - type        : connection
        host        : 127.0.0.1
        socket_type : udp
        port        : 123
        protocol    : ntp
        action      : restart

  varnish:
    type: process
    config:
      pidfile: "/var/run/varnish.pid"
      start_program : "/etc/init.d/varnish start"
      stop_program  : "/etc/init.d/varnish stop"
    tests:
      - type: connection
        host: 127.0.0.1
        port: 8080
        protocol: http
        protocol_test:
          request: /health.varnish
      - type      : 'cpu(user)'
        operator  : '>'
        value     : 60%
        tolerance :
          cycles  : 2
      - type      : 'children'
        operator  : '>'
        value     : 150

  httpd:
    type: service
    config:
      pidfile : "/var/run/httpd/httpd.pid"
      binary  : "/usr/sbin/httpd"
      initd   : "/etc/init.d/httpd"
    tests:
      - type: connection
        host: 127.0.0.1
        port: 80
        protocol: http
```

