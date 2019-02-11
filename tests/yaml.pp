$yaml = @("YAML")
---
  somefs :
    type     : filesystem
    config   :
      path   : /mount/somefs
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
      pidfile       : /var/run/sshd.pid
      program_start : /etc/init.d/sshd start
      program_stop  : /etc/init.d/sshd stop
    tests  :
      - type     : connection
        host     : 127.0.0.1
        port     : 22
        protocol : ssh
        action   : restart

  php5-fpm :
    type    : process
    config  :
      pidfile       : /var/run/php5-fpm.pid
      program_start : /etc/init.d/php5-fpm start
      program_stop  : /etc/init.d/php5-fpm stop
    tests  :
      - type          : connection
        host          : 127.0.0.1
        port          : 9000
        socket_type   : TCP
        protocol      : GENERIC
        protocol_test :
          - send   : '"\0x01\0x09\0x00\0x00\0x00\0x00\0x08\0x00\0x00\0x00\0x00\0x00\0x00\0x00\0x00\0x00"'
            expect : '"\0x01\0x0A"'
        action   : restart

  ntp :
    type   : process
    config :
      pidfile       : /var/run/ntpd.pid
      program_start : /etc/init.d/ntpd start
      program_stop  : /etc/init.d/ntpd stop
    tests  :
      - type        : connection
        host        : 127.0.0.1
        socket_type : udp
        port        : 123
        protocol    : ntp
        action      : restart

  varnish :
    type   : process
    config :
      pidfile       : /var/run/varnish.pid
      program_start : /etc/init.d/varnish start
      program_stop  : /etc/init.d/varnish stop
    tests  :
      - type: connection
        host: 127.0.0.1
        port: 8080
        protocol: http
        protocol_test:
          request: /health.varnish
      - type      : cpu(user)
        operator  : '>'
        value     : 60%
        tolerance :
          cycles  : 2
      - type      : children
        operator  : '>'
        value     : 150

  httpd :
    type   : service
    config :
      pidfile : /var/run/httpd/httpd.pid
      binary  : /usr/sbin/httpd
    tests  :
      - type: connection
        host: 127.0.0.1
        port: 80
        protocol: http

# Notice: Param 'HOSTHEADER' changed to 'HTTP HEADERS' in monit 5.9
# see https://mmonit.com/monit/changes/
  http_headers :
    type: host
    config:
      address: 127.0.0.1
    tests:
      - type: connection
        host: 127.0.0.1
        port: 80
        protocol: http
        protocol_test:
          request: /
          status: 200
          http headers: '[host: www.example.com]'
        action: restart

  custom-script :
    type   : program
    config :
      path   : /path/to/custom/pingcheck.sh
    tests  :
      - type      : status
        operator  : '!='
        value     : 0
        tolerance :
          cycles  : 2
        action    : exec
        exec      : sudo /sbin/reboot

| YAML

$checks = parseyaml($yaml)

class { '::monit':
  checks => $checks,
}

