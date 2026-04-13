Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  namespace :api do
    namespace :v1 do
      resources :groups, only: [ :index, :create, :update, :destroy ]
      resources :users, only: [ :index, :create, :update, :destroy ]
      resources :categories, only: [ :index, :create, :update, :destroy ]
      resources :transactions, only: [ :index, :create, :update, :destroy ]
      resources :monthly_budgets, only: [ :index, :create, :update, :destroy ]

      get "reports/monthly", to: "reports#monthly"
    end
  end
end
