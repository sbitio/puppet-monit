# Changelog

## [2.0.0](https://github.com/sbitio/puppet-monit/tree/2.0.0) (2020-01-15)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/1.1.0...2.0.0)

**Closed issues:**

- Deprecate hiera\_merge\_strategy [\#42](https://github.com/sbitio/puppet-monit/issues/42)
- Check all filesystems by default \(not only /\) [\#41](https://github.com/sbitio/puppet-monit/issues/41)
- Upgrade module to support Puppet4 [\#35](https://github.com/sbitio/puppet-monit/issues/35)
- Make IP address parameter optional [\#33](https://github.com/sbitio/puppet-monit/issues/33)
- Wrong permissions for monitrc [\#32](https://github.com/sbitio/puppet-monit/issues/32)
- Concat requirements [\#29](https://github.com/sbitio/puppet-monit/issues/29)
- permissions of monitrc on Debian 9.1 - monit    1:5.20.0-6   [\#28](https://github.com/sbitio/puppet-monit/issues/28)

**Merged pull requests:**

- Add support for EXIST check [\#39](https://github.com/sbitio/puppet-monit/pull/39) ([NITEMAN](https://github.com/NITEMAN))
- Added FreeBSD support [\#38](https://github.com/sbitio/puppet-monit/pull/38) ([jurgenweber](https://github.com/jurgenweber))
- Make bind IP address optional. [\#31](https://github.com/sbitio/puppet-monit/pull/31) ([wdec](https://github.com/wdec))

## [1.1.0](https://github.com/sbitio/puppet-monit/tree/1.1.0) (2017-08-21)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/1.0.0...1.1.0)

**Closed issues:**

- On cetons missing repo epel [\#26](https://github.com/sbitio/puppet-monit/issues/26)
- Checking error in host.pp [\#22](https://github.com/sbitio/puppet-monit/issues/22)
- monit won't start on Debian Squeeze [\#14](https://github.com/sbitio/puppet-monit/issues/14)
- Puppet 4 and puppetserver setup \> add puppetlabs-concat to fix this dependency issue [\#12](https://github.com/sbitio/puppet-monit/issues/12)
- template vars are missing scope [\#11](https://github.com/sbitio/puppet-monit/issues/11)

**Merged pull requests:**

- Add example for Centos 7 [\#27](https://github.com/sbitio/puppet-monit/pull/27) ([nvtkaszpir](https://github.com/nvtkaszpir))
- Fixed the host check having an OR-check when it should be an AND-check [\#24](https://github.com/sbitio/puppet-monit/pull/24) ([aepgit](https://github.com/aepgit))
- Added checksum test for files. [\#21](https://github.com/sbitio/puppet-monit/pull/21) ([triforce](https://github.com/triforce))
- Update instance.pp [\#19](https://github.com/sbitio/puppet-monit/pull/19) ([MNiedzielski](https://github.com/MNiedzielski))
- missing space for tests before UNIXSOCKET [\#18](https://github.com/sbitio/puppet-monit/pull/18) ([gytisgreitai](https://github.com/gytisgreitai))
- Make monit auto-start on Debian Squeeze, as it does not do so by default when installed [\#15](https://github.com/sbitio/puppet-monit/pull/15) ([thatgraemeguy](https://github.com/thatgraemeguy))
- fix 'http headers' param in test-validation [\#13](https://github.com/sbitio/puppet-monit/pull/13) ([ThomasLohner](https://github.com/ThomasLohner))
- Made monit's PROGRAM STATUS TESTING work, made ACTION EXEC work, made exec path accept parameters. [\#9](https://github.com/sbitio/puppet-monit/pull/9) ([derjohn](https://github.com/derjohn))
- Support hiera\_hash for custom checks [\#8](https://github.com/sbitio/puppet-monit/pull/8) ([himpich](https://github.com/himpich))

## [1.0.0](https://github.com/sbitio/puppet-monit/tree/1.0.0) (2015-07-07)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/0.3.3...1.0.0)

## [0.3.3](https://github.com/sbitio/puppet-monit/tree/0.3.3) (2015-07-07)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/0.3.2...0.3.3)

## [0.3.2](https://github.com/sbitio/puppet-monit/tree/0.3.2) (2015-07-06)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/0.3.1...0.3.2)

**Closed issues:**

- Systemd file paths differs on Debian and Redhat/Centos \(regresion introduced in 4ff388c\) [\#6](https://github.com/sbitio/puppet-monit/issues/6)

**Merged pull requests:**

- Fix \#6. Systemd file paths differs on Debian and Redhat/Centos [\#7](https://github.com/sbitio/puppet-monit/pull/7) ([NITEMAN](https://github.com/NITEMAN))

## [0.3.1](https://github.com/sbitio/puppet-monit/tree/0.3.1) (2015-07-06)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/0.3.0...0.3.1)

## [0.3.0](https://github.com/sbitio/puppet-monit/tree/0.3.0) (2015-07-06)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/0.2.1...0.3.0)

**Closed issues:**

- Add support for MATCHING in services \(when no PID available\) [\#4](https://github.com/sbitio/puppet-monit/issues/4)
- Add "default" support for CentOS 7 \(systemd instead of initd\) [\#3](https://github.com/sbitio/puppet-monit/issues/3)
- Improve quality score [\#2](https://github.com/sbitio/puppet-monit/issues/2)
- monit\_validate\_tests.rb: warning: already initialized constant  [\#1](https://github.com/sbitio/puppet-monit/issues/1)

**Merged pull requests:**

- Update monit\_validate\_tests.rb [\#5](https://github.com/sbitio/puppet-monit/pull/5) ([MNiedzielski](https://github.com/MNiedzielski))

## [0.2.1](https://github.com/sbitio/puppet-monit/tree/0.2.1) (2015-04-23)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/0.2.0...0.2.1)

## [0.2.0](https://github.com/sbitio/puppet-monit/tree/0.2.0) (2015-04-23)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/0.1.0...0.2.0)

## [0.1.0](https://github.com/sbitio/puppet-monit/tree/0.1.0) (2015-04-23)

[Full Changelog](https://github.com/sbitio/puppet-monit/compare/2bb4a22853b8dd5003b4cdf90a41f2f94971c69b...0.1.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
