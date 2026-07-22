Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Test error handling endpoints
  namespace :api do
    namespace :v1 do
      get "test_errors/record_not_found", to: "test_errors#record_not_found"
      get "test_errors/record_invalid", to: "test_errors#record_invalid"
      get "test_errors/custom_error", to: "test_errors#custom_error"
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
