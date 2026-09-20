Rails.application.routes.draw do
  # health check for the proxy and uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # JSON API for the Vue frontend
  get "menu", to: "menu#show"
  resources :quotes, only: :create
  resources :orders, only: :create
end
