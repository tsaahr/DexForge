Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

  root 'pokedex#index'
  get '/pokemon/:name', to: 'pokedex#show', as: 'pokemon'
  
  resources :pokedex, only: [:index, :show], param: :id
  
  devise_for :users

end
