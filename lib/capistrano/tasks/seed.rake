# The menu is data the app cannot run without; db/seeds.rb is idempotent, so it
# runs on every deploy right after the migrations.
namespace :deploy do
  desc "Load the menu (db:seed, idempotent)"
  task :seed do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:seed"
        end
      end
    end
  end
end

after "deploy:migrate", "deploy:seed"
