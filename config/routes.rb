Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

  root 'pokedex#index'
  get '/pokemon/:name', to: 'pokedex#show', as: 'pokemon'
  
  Rails.application.routes.draw do
    resources :pokedex, only: [:index, :show]
  end

end
