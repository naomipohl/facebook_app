Rails.application.routes.draw do
  resources :statuses
  root 'welcome#index'

  resources :users do
    member do
      delete 'remove_friendship'
      post 'send_friend_request'
      patch 'accept_friend_request'
    end
  end

  resources :statuses, :except => [:index, :show]

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/friend_requests', to: 'users#friend_requests'
end
