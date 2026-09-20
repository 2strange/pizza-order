# Two commands, nothing else:
#   cap production setup    # once: keys, the Let's Encrypt certificate, the Puma service
#   cap production deploy   # every time: code, bundle, Vite build, migrations, seed, nginx, restart
hosts = SERVERS.fetch("production")

server hosts.fetch("proxy_ip"), user: hosts.fetch("user"), roles: %w[proxy], no_release: true
server hosts.fetch("app_ip"),   user: hosts.fetch("user"), roles: %w[app db web]

set :user,      hosts.fetch("user")
set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}_#{fetch(:stage)}"
set :rails_env, "production"

set :puma_hooks,    true
set :app_instances, 1

set :nginx_upstream_host, hosts.fetch("upstream_host")
set :nginx_upstream_port, hosts.fetch("upstream_port")
set :nginx_domains,       hosts.fetch("domains")
set :nginx_use_ssl,       true
set :certbot_email,       "trendgegner@gmail.com"
set :certbot_roles,       [ :proxy ]
set :certbot_webroot,     "/var/www/html"
