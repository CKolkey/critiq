Rails.application.routes.draw do

  get '/auth/installbot', to: 'slack#installbot'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root to: 'pages#home'

  post '/api/events', to: 'slack#webhook'

  resources :surveys, only: [:index, :new, :create, :edit, :update, :show, :destroy] do
    resources :questions, only: [:new, :create, :show]
  end

  patch '/surveys/:id', to: 'survey#update_and_send', as: :send;

  # Sidekiq Web UI, only for admins.
 require "sidekiq/web"
 authenticate :user, lambda { |u| u.admin } do
   mount Sidekiq::Web => '/sidekiq'
 end
end
