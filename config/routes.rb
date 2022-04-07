Rails.application.routes.draw do
  root 'sessions#home'

  # user routes
  resources :users, only: %i[new create edit update show destroy]

  # session routes
  get '/login', to: 'sessions#login'
  post '/login', to: 'sessions#create'
  post '/logout', to: 'sessions#destroy'
  get '/logout', to: 'sessions#destroy'
  delete '/sessions', to: 'sessions#destroy'
end
