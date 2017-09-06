# monit

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with monit](#setup)
    * [What monit affects](#what-monit-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with monit](#beginning-with-monit)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Description

Performs installation and configuration of Monit service, along with fine
grained definition of checks.

All check types provided by Monit are supported. Namely: `directory`, `fifo`,
`file`, `filesystem`, `host`, `process`, `program`, and `system`.

In adition to primitive types, a compound check type is provided: `service`.
It is a set of primitives to check a service's init script, binary and process.

## Setup

### Beginning with monit

`include '::monit'` is enough to get you up and running. It will configure the basis of monit, with HTTP server listening at `localhost:2812` and a system check for `LOADAVG`, `CPU`, `MEMORY` and `FILESYSTEM` at `/`.

To pass in parameters and override default configuration:

```puppet
class { '::monit':
  check_interval    => 60,
  check_start_delay => 120,
  mailserver        => 'localhost',
  eventqueue        => true,
  alerts            => ['root@localhost', 'sla1@example.com only on { timeout, nonexist }'],
  httpserver        => true,
  httpserver_allow  => ['admin:secret'],
}
```


## Usage

All parameters for the monit module are contained within the main `::monit`
class, so for any function of the module, set the options you want.
See the common usages below for examples.

Check types are implemented by defined types, named after `monit::check::TYPE`.
All check types have several configuration options in common (ex: group,
priority, alerts, dependencies, etc.), along with the check specific options.

On the other hand, `monit::check` defined type is a facade for all check types.
It works as a single entry point to declare any type of check in the same way.
Common configuration options are parameters of the defined type, and check
specific options are passed through a hash in the `config` parameter.

So there're several entry points to declare your own checks:

 * Create an instance of the specific defined type for the given check (ex: `monit::check::TYPE`)
 * Create an instance of the generic `monit::check` defined type, and pass in the details of the check
 * Pass in a hash of checks to `::monit` class. This enables providing the checks from Hiera, with your preferred merge strategy


### Install and enable monit

```puppet
include '::monit'
```

### Customize the system check

```puppet
class { '::monit':
  system_cpu_wait       => '40%',
  system_memory         => '84%',
  system_loadavg_1min   => 14.0,
  system_fs_space_usage => '88%',
  system_fs             => ['/', '/mnt/backups'],
}
```

### Declare a check by instantiating the check's defined type

```puppet
include ::monit

monit::check::filesystem { 'somefs':
  path  => '/mount/somefs',
  tests => [
    {'type' => 'fsflags'}
    {'type' => 'permission', 'value' => '0755'}
    {'type' => 'space', 'operator' => '>', 'value' => '80%'}
  ]
}
```


### Declare a check by instantiating the generic check defined type

```puppet
include ::monit

# Add a check for ntp process.
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
```

### Provide the monit class with a check for ssh service

```puppet
include ::monit

class { '::monit':
  checks => {
    'sshd' => {
      'type'    => 'service',
      'config' => {
        'pidfile'       => '/var/run/sshd.pid',
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
```


### Provide full module config and checks from Hiera

```yaml
# Main monitrc configuration options.
monit::check_interval    : '60'
monit::check_start_delay : '120'
monit::mailserver        : 'localhost'
monit::eventqueue        : true
monit::alerts            :
  - 'root@localhost'
  - 'sla1@example.com only on { timeout, nonexist }'
monit::httpserver        : true
monit::httpserver_allow  :
  - 'admin:secret'

# Tweak system check.
monit::system_fs         : ['/', '/mnt/backups']

# Add some checks.
monit::checks :

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
```

There's a bunch of examples for configuring real services across Debian and
RedHat families in [sbitio/ducktape](https://github.com/sbitio/puppet-ducktape) module.
Please refer to [manifests/*/external/monit.pp](https://github.com/sbitio/puppet-ducktape/tree/master/manifests)
files.


## Reference

See Puppet Strings doc at [doc/index.html](https://github.com/sbitio/puppet-monit/blob/master/doc/index.html)


## Limitations

This module requires Puppet 4.x, and is compatible with the following OSes/versions:

 * Debian 7, 8
 * RedHat/CentOS 7,8
 * Ubuntu 12.04, 14.04

For Puppet 3 or older versions of Debian, please use 1.x.x releases.


## Development

Development happens on [GitHub](https://github.com/sbitio/puppet-monit).

Please log issues for any bug report, feature or support request.

Pull requests are welcome.


## License

MIT License, see LICENSE file


## Contact

Use contact form on http://sbit.io
