Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :team_members, only: [:index, :create, :update]
      resources :support_requests, only: [:index, :show, :create, :update] do
        resources :comments, only: [:create]
      end
      get "dashboard", to: "dashboard#index"
    end
  end
end
