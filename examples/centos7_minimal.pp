# This is tested to work under puppet 3.8.x
# Centos 7 requires extra module to manage yum repo
# install it with command
#   puppet module install 'stahnma-epel'
# or add it to Puppetfile as:
#   mode 'stahnma-epel'

# anything else should be defined with hiera

node default {

  # provided by stahnma-epel
  include ::epel

  include ::monit
  Class['epel'] -> Class['monit::install'] # cannot do just Class['monit'] because the way module is constructed

}
