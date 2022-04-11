Rails.application.routes.draw do
  root 'documents#index'

  # user routes
  resources :users, only: %i[new create edit update show destroy]

  get '/share/', to: 'documents#share'
  get '/download', to: 'documents#download'
  resources :documents

  # session routes
  get '/login', to: 'sessions#login'
  post '/login', to: 'sessions#create'
  post '/logout', to: 'sessions#destroy'
  get '/logout', to: 'sessions#destroy'
  delete '/sessions', to: 'sessions#destroy'
end
