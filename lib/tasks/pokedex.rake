namespace :pokedex do
  desc "Fetch and store Pokémon data from the PokéAPI"
  task seed: :environment do
    (1..151).each do |id|
      puts "Fetching Pokémon ##{id}"
      Pokemon.fetch_or_create(id)
    end
  end
end
