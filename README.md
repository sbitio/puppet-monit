# Puppet Monit

[![puppet forge version](https://img.shields.io/puppetforge/v/sbitio/monit.svg)](http://forge.puppetlabs.com/sbitio/monit) [![last tag](https://img.shields.io/github/tag/sbitio/puppet-monit.svg)](https://github.com/sbitio/puppet-monit/tags)

Performs installation and configuration of Monit service,
along with fine grained definition of checks.

All check types provided by Monit are supported. Namely: `directory`, `fifo`,
`file`, `filesystem`, `host`, `process`, `program`, and `system`.

In adition to primitive types, a compound check type is provided: `service`.
It is a set of primitives to check a service's init script, binary and process.


## Classes and Defined Types

### Class: `monit`

`monit` class is the responsible of installing and configuring the service.
Almost all configuration options for `monitrc` are exposed as class parameters.

Also accepts a `checks` parameter, to pass in checks definitions, easy provided
from Hiera.

Lastly, this class also configures a `system` check with sane defaults. It can be
disabled or tweaked to fit your needs. This check includes loadavg, cpu,
memory, swap and filesytem tests.

See [https://github.com/sbitio/puppet-monit/blob/master/manifests/init.pp](manifests/init.pp)
for a reference of all supported parameters.


### Defined type: `monit::check`

Check types are implemented by defined types, named after `monit::check::TYPE`.
All check types have several configuration options in common (ex: group,
priority, alerts, dependencies, etc.), along with the check specific options.

See [https://github.com/sbitio/puppet-monit/blob/master/manifests/check](manifests/check/*.pp)
for a reference of parameters accepted by each check type.

On the other hand, `monit::check` defined type is a facade for all check types.
It works as a single entry point to declare any type of check in the same way.
Common configuration options are parameters of the defiend type, and check
specific options are passed through a hash in the `config` parameter.

See [https://github.com/sbitio/puppet-monit/blob/master/manifests/check.pp](manifests/check.pp)
for a reference of all parameters accepted by `monit::check`.


### Example of use


#### Puppet code

There's a bunch of examples for configuring real services across Debian and
RedHat families in [https://github.com/sbitio/puppet-ducktape](sbitio/ducktape).
Please refer to [https://github.com/sbitio/puppet-ducktape/tree/master/manifests](manifests/*/external/monit.pp)
files.


#### Hiera

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
    type     : 'filesystem'
    config   :
      path   : '/mount/somefs'
    tests    :
      - type: 'fsflags'
      - type: 'permission'
        value: '0755'
      - type: 'space'
        operator: '>'
        value: '80%'

  sshd :
    type    : 'process'
    config  :
      pidfile       : '/var/run/sshd.pid'
      start_program : '/etc/init.d/sshd start'
      stop_program  : '/etc/init.d/sshd stop'
    tests  :
      - type     : 'connection'
        host     : '127.0.0.1'
        port     : '22'
        protocol : 'ssh'
        action   : 'restart'

  php5-fpm :
    type    : process
    config  :
      pidfile       : '/var/run/php5-fpm.pid'
      binary        : '/usr/sbin/php5-fpm'
      start_program : '/etc/init.d/php5-fpm start'
      stop_program  : '/etc/init.d/php5-fpm stop'
    tests  :
      - type          : 'connection'
        host          : '127.0.0.1'
        port          : '9000''
        socket_type   : 'TCP'
        protocol      : 'GENERIC'
        protocol_test :
          - send   : '"\0x01\0x09\0x00\0x00\0x00\0x00\0x08\0x00\0x00\0x00\0x00\0x00\0x00\0x00\0x00\0x00"'
            expect : '"\0x01\0x0A"'
        action   : 'restart'

  ntp:
    type   : process
    config :
      pidfile       : '/var/run/ntpd.pid'
      start_program : '/etc/init.d/ntpd start'
      stop_program  : '/etc/init.d/ntpd stop'
    tests  :
      - type        : connection
        host        : 127.0.0.1
        socket_type : udp
        port        : 123
        protocol    : ntp
        action      : restart

  varnish:
    type   : 'process'
    config :
      pidfile       : '/var/run/varnish.pid'
      start_program : '/etc/init.d/varnish start'
      stop_program  : '/etc/init.d/varnish stop'
    tests  :
      - type: 'connection'
        host: '127.0.0.1'
        port: '8080'
        protocol: 'http'
        protocol_test:
          request: '/health.varnish'
      - type      : 'cpu(user)'
        operator  : '>'
        value     : '60%'
        tolerance :
          cycles  : '2'
      - type      : 'children'
        operator  : '>'
        value     : '150'

  httpd:
    type   : 'service'
    config :
      pidfile : '/var/run/httpd/httpd.pid'
      binary  : '/usr/sbin/httpd'
      initd   : '/etc/init.d/httpd'
    tests  :
      - type: 'connection'
        host: '127.0.0.1'
        port: '80'
        protocol: 'http'
```

## License

MIT License, see LICENSE file

## Contact

Use contact form on http://sbit.io

## Support

Please log tickets and issues on [GitHub](https://github.com/sbitio/puppet-monit)

