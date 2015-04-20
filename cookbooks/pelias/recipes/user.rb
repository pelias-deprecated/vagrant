#
# Cookbook Name:: pelias
# Recipe:: user
#

# is someone tells us to run as root,
#   don't muck with the account
#
user_account node[:pelias][:user][:name] do
  manage_home   true
  create_group  true
  ssh_keygen    false
  home          node[:pelias][:user][:home]
  not_if        { node[:pelias][:user][:name] == 'root' }
end
