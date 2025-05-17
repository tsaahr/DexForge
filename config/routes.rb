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

  get "/capture", to: "capture#encounter"
  post "/capture", to: "capture#encounter", as: :capture_encounter

  get '/capture/:id/battle', to: 'capture#battle'
  post '/capture/:id/battle', to: 'capture#battle', as: 'capture_battle'
  post '/capture/:id/battle/next_turn', to: 'capture#next_turn_battle', as: 'next_turn_capture_battle'
  


  devise_for :users


end
