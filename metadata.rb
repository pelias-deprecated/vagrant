name             'pelias'
maintainer       'Mapzen'
maintainer_email 'grant@mapzen.com'
license          'GPL'
description      'Installs/Configures pelias in a Vagrant environment. Intended for educational and development purposes.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w(
  apt
  git
  elasticsearch
  java
  user
  runit
  nodejs
  ulimit
).each do |dep|
  depends dep
end

%w(ubuntu).each do |os|
  supports os
end
