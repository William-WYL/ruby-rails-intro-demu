Rails.application.routes.draw do
  root "products#index"

  resources :users
  resources :products, only: [:index, :show]
  resources :categories

  get "about", to: "pages#about"

  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes (commented out)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
