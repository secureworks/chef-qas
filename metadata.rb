name             'qas'
maintainer       'Zach Morgan (zmorgan)'
maintainer_email 'zmorgan@secureworks.com'
license          'Apache License, Version 2.0'
description      'Installs/Configures qas'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.0.2'

# assume we support redhat, other OSes include: ubuntu debian redhat centos fedora oracle suse freebsd openbsd mac_os_x mac_os_x_server windows aix
# TODO: TEST MORE OPERATING SYSTEMS!!!
%w{ redhat }.each do |os|
  supports os
end

depends 'selinux_policy', '~> 0.6'
depends 'ohai'
