namespace :pokedex do
  desc "update"
  task seed: :environment do
    (1..151).each do |id|
      puts "Updating Pokémon ##{id}"
      Pokemon.fetch_or_update(id)
    end
  end
end
