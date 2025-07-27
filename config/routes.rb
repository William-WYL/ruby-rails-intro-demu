Rails.application.routes.draw do
  root "products#index"

  resources :users
  resources :products, only: [:index, :show]
  resources :categories
  resources :orders, only: [:index, :show]

  get "about", to: "pages#about"

  get "up" => "rails/health#show", as: :rails_health_check
end
