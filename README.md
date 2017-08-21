# Puppet Monit

[![puppet forge version](https://img.shields.io/puppetforge/v/sbitio/monit.svg)](http://forge.puppetlabs.com/sbitio/monit) [![last tag](https://img.shields.io/github/tag/sbitio/puppet-monit.svg)](https://github.com/sbitio/puppet-monit/tags)

Performs installation and configuration of Monit service,
along with fine grained definition of checks.

All check types provided by Monit are supported. Namely: `directory`, `fifo`,
`file`, `filesystem`, `host`, `process`, `program`, and `system`.

In adition to primitive types, a compound check type is provided: `service`.
It is a set of primitives to check a service's init script, binary and process.

`service` check type can work with `sysv`, `systemd` or `upstart`. In 0.3.x
series it defaults to `sysv` for compatibility reasons. From 1.0.x onwards it
defaults to the init system that each supported OS configures by default.
The init type to use can be also set per service. See below for details.

Use 1.x.x releases for Puppet 3.x and 2.x.x for Puppet 4.


## Classes and Defined Types

### Class: `monit`

`monit` class is the responsible of installing and configuring the Monit
service. Almost all configuration options for `monitrc` are exposed as class
parameters.

In addition to Monit configuration options, this class accepts other parameters:

 * `init_system`, to set globally the default init system for `service` checks.

 * `checks`, useful to pass in Monit checks declared in Hiera.

If your hiera setup supports a hierarchy structure, you can set
'monit::hiera_merge_strategy' to 'hiera_hash' in order use the hiera_hash function for
config merging.

Lastly, this class also configures a `system` check with sane defaults. It can
be disabled or tweaked to fit your needs. This check includes loadavg, cpu,
memory, swap and filesytem tests.

See [manifests/init.pp](https://github.com/sbitio/puppet-monit/blob/master/manifests/init.pp)
for a reference of all supported parameters.


### Defined type: `monit::check`

Check types are implemented by defined types, named after `monit::check::TYPE`.
All check types have several configuration options in common (ex: group,
priority, alerts, dependencies, etc.), along with the check specific options.

See [manifests/check/*.pp](https://github.com/sbitio/puppet-monit/blob/master/manifests/check)
for a reference of parameters accepted by each check type.

On the other hand, `monit::check` defined type is a facade for all check types.
It works as a single entry point to declare any type of check in the same way.
Common configuration options are parameters of the defined type, and check
specific options are passed through a hash in the `config` parameter.

See [manifests/check.pp](https://github.com/sbitio/puppet-monit/blob/master/manifests/check.pp)
for a reference of all parameters accepted by `monit::check`.


### Example of use


#### Puppet code

There's a bunch of examples for configuring real services across Debian and
RedHat families in [sbitio/ducktape](https://github.com/sbitio/puppet-ducktape).
Please refer to [manifests/*/external/monit.pp](https://github.com/sbitio/puppet-ducktape/tree/master/manifests)
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
      program_start : '/etc/init.d/sshd start'
      program_stop  : '/etc/init.d/sshd stop'
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
      program_start : '/etc/init.d/php5-fpm start'
      program_stop  : '/etc/init.d/php5-fpm stop'
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
      program_start : '/etc/init.d/ntpd start'
      program_stop  : '/etc/init.d/ntpd stop'
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
      program_start : '/etc/init.d/varnish start'
      program_stop  : '/etc/init.d/varnish stop'
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

  # Notice: Param 'HOSTHEADER' changed to 'HTTP HEADERS' in monit 5.9
  # see https://mmonit.com/monit/changes/		
  http_headers:
    type: host
    config:
      address: '127.0.0.1'
    tests:
      - type: 'connection'
        host: '127.0.0.1'
        port: '80'
        protocol: 'http'
        protocol_test:
          request: '/'
          status: 200
          http headers: '[host: www.example.com]'
        action: restart

 custom-script:
   type   : 'program'
   config :
     path   : "/path/to/custom/pingcheck.sh"
   tests  :
     - type      : 'status'
       operator  : '!='
       value     : '0'
       tolerance :
         cycles  : '2'
       action    : 'exec'
       exec      : 'sudo /sbin/reboot'
```

## License

MIT License, see LICENSE file

## Contact

Use contact form on http://sbit.io

## Support

Please log tickets and issues on [GitHub](https://github.com/sbitio/puppet-monit)

