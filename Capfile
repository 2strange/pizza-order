require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require "capistrano/rvm"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"

require "capistrano/recipes2go/keys"
require "capistrano/recipes2go/nvm"
require "capistrano/recipes2go/puma"
require "capistrano/recipes2go/systemd"
require "capistrano/recipes2go/proxy_nginx"
require "capistrano/recipes2go/certbot"

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
