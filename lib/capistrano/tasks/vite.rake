# The app has no Sprockets/Propshaft, so capistrano/rails/assets (which expects
# their manifest) is not loaded; Vite builds through the same rake task.
namespace :deploy do
  desc "Build the Vite assets"
  task :vite_build do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "assets:precompile"
        end
      end
    end
  end
end

after "deploy:updated", "deploy:vite_build"
