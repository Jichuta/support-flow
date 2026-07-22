Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :team_members, only: [:index, :create, :update]
      resources :support_requests, only: [:index, :show, :create, :update] do
        resources :comments, only: [:create]
      end
      get "dashboard", to: "dashboard#index"
      get "test_errors/record_not_found", to: "test_errors#record_not_found"
      get "test_errors/record_invalid", to: "test_errors#record_invalid"
      get "test_errors/custom_error", to: "test_errors#custom_error"
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
