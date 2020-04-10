Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :reports 

      # User can only manipulate himself
      get 'users', controller: :users, action: :index
      patch 'users', controller: :users, action: :update
      delete 'users', controller: :users, action: :destroy
    end
  end

  patch 'recovery', to: 'recovery#update', as: :recovery
  post 'reset_password', to: 'recovery#create', as: :reset_password

  post 'refresh', controller: :refresh, action: :create
  post 'auth', controller: :auth, action: :create
  delete 'auth', controller: :auth, action: :destroy
  # delete 'auth/destroy_by_refresh', to: 'auth#destroy_by_refresh', as: :destroy_by_refresh 
  post 'signup', controller: :signup, action: :create
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
