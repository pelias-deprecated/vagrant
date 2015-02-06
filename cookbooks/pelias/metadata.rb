name             'pelias'
maintainer       'Mapzen'
maintainer_email 'grant@mapzen.com'
license          'GPL'
description      'Installs/configures Pelias in a vagrant environment. Intended for education and development.'
version          '0.3.0'

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
