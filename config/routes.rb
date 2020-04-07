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

  post 'refresh', controller: :refresh, action: :create
  post 'auth', controller: :auth, action: :create
  post 'auth/recover', controller: :auth, action: :recover
  delete 'auth', controller: :auth, action: :destroy
  post 'signup', controller: :signup, action: :create
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
