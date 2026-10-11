Rails.application.routes.draw do
  root "games#index"

  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token
  resource :registration, only: %i[new create]
  resource :profile, only: %i[show edit update]

  resources :recommendations, only: %i[index] do
    post :refresh, on: :collection
  end

  resources :games, only: %i[index show] do
    resource :interaction, only: %i[create update destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
