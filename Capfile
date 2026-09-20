require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require "capistrano/rvm"
require "capistrano/bundler"
require "capistrano/rails/migrations"

# Order matters for `cap setup`: keys, then the certificate, then Puma (which can
# only start once a release exists — its start is the last step on purpose).
require "capistrano/recipes2go/keys"
require "capistrano/recipes2go/nvm"
require "capistrano/recipes2go/proxy_nginx"
require "capistrano/recipes2go/certbot"
require "capistrano/recipes2go/systemd"
require "capistrano/recipes2go/puma"

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
