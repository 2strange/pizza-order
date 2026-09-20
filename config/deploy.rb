# Deploy with Capistrano and capistrano-recipes2go: a proxy host terminates TLS and
# forwards to the app host, where nginx serves the Vite build and hands the rest
# to Puma (systemd). Hosts and ports live in config/deploy/servers.yml, which is
# not committed — see servers.example.yml.
lock "~> 3.20"

SERVERS = YAML.safe_load(File.read(File.expand_path("deploy/servers.yml", __dir__)))

set :application, "pizza_order"
set :repo_url,    "git@github.com:2strange/pizza-order.git"
set :branch,      "deploy"
set :keep_releases, 3

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "storage", "node_modules"

set :rvm_ruby_version, "3.4.2"
set :rvm_custom_path,  "/usr/local/rvm"
set :rvm_map_bins,     %w[gem rake ruby bundle rails]
set :rvm_roles,        [ :app, :db, :web ]   # the proxy has no Ruby

# Node for the Vite build (assets:precompile spawns `vite build`): pin the version
# on the PATH instead of touching the server-wide nvm default.
set :nvm_node_version, "22.23.1"
set :nvm_roles,        [ :app ]
set :default_env, { "PATH" => "$HOME/.nvm/versions/node/v#{fetch(:nvm_node_version)}/bin:$PATH" }
