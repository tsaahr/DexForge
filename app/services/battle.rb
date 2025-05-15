# app/services/battle.rb
class Battle
  attr_reader :pokemon1, :pokemon2

  def initialize(pokemon1, pokemon2)
    @pokemon1 = pokemon1
    @pokemon2 = pokemon2
    @turn = 1

    # Initialize current HP if nil
    [@pokemon1, @pokemon2].each do |p|
      p.current_hp ||= p.hp
    end
  end

  def start
    puts "The battle begins between #{pokemon_name(pokemon1)} and #{pokemon_name(pokemon2)}!"

    until battle_over?
      puts "\n--- Turn #{@turn} ---"
      execute_turn
      @turn += 1
    end

    declare_winner
  end

  private

  def execute_turn
    attacker, defender = decide_turn_order

    puts "#{pokemon_name(attacker)} attacks #{pokemon_name(defender)}!"

    damage = calculate_damage(attacker, defender)
    defender.current_hp -= damage
    defender.current_hp = 0 if defender.current_hp < 0
    defender.save!

    puts "#{pokemon_name(defender)} took #{damage} damage and has #{defender.current_hp} HP remaining."
  end

  def decide_turn_order
    if pokemon1.speed >= pokemon2.speed
      [pokemon1, pokemon2]
    else
      [pokemon2, pokemon1]
    end
  end

  # Basic damage formula: attack - (defense / 2), minimum 1 damage
  def calculate_damage(attacker, defender)
    damage = attacker.attack - (defender.defense / 2)
    damage > 0 ? damage : 1
  end

  def battle_over?
    pokemon1.current_hp <= 0 || pokemon2.current_hp <= 0
  end

  def declare_winner
    winner = pokemon1.current_hp > 0 ? pokemon1 : pokemon2
    loser = winner == pokemon1 ? pokemon2 : pokemon1

    puts "\n#{pokemon_name(loser)} has been defeated!"
    puts "#{pokemon_name(winner)} wins the battle!"
  end

  def pokemon_name(user_pokemon)
    user_pokemon.nickname.present? ? user_pokemon.nickname : user_pokemon.pokemon.name.capitalize
  end
end
