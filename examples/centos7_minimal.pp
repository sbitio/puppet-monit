# This is tested to work under puppet 3.8.x
#
# Centos 7 requires extra module to manage yum repo:

# Install it with command:
#   `puppet module install 'stahnma-epel'`

# Or add it to Puppetfile as:
#   `mod 'stahnma-epel'`

# Anything else should be defined with hiera.

node default {

  # Provided by stahnma-epel
  include ::epel

  include ::monit
  # Set precedence. Cannot do just Class['monit']
  # because the way module is constructed.
  Class['epel'] -> Class['monit::install']

}
