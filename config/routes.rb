Rails.application.routes.draw do
  get 'starters/new'
  get 'starters/create'
  get 'my_pokemons/index'
  get 'capture/index'

  get "up" => "rails/health#show", as: :rails_health_check

  root 'pokedex#index'
  get '/pokemon/:name', to: 'pokedex#show', as: 'pokemon'
  
  resources :pokedex, only: [:index, :show], param: :id
  
  # resource :capture, only: [:index]
  get 'capture', to: 'capture#index'

  get "my_pokemons", to: "my_pokemons#index"

  get '/starter', to: 'starters#new', as: :starter_selection
  post '/starter', to: 'starters#create'



  devise_for :users


end
