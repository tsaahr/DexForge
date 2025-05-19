namespace :cleanup do
  desc "Remove WildPokemons and WildBattles older than 10 minutes"
  task remove_old_wilds: :environment do
    WildBattle.where("created_at < ?", 10.minutes.ago).delete_all
    WildPokemon.where("created_at < ?", 10.minutes.ago).delete_all
    puts "Deleted wild battles and wild pokemons older than 10 minutes."
  end
end
