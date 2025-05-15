class Battle < ApplicationRecord
  belongs_to :user_pokemon_1, class_name: "UserPokemon"
  belongs_to :user_pokemon_2, class_name: "UserPokemon"
  belongs_to :winner, class_name: 'UserPokemon', optional: true


  has_many :battle_turns, dependent: :destroy

  enum status: {
    pending: 'pending',
    ongoing: 'ongoing',
    finished: 'finished'
  }

  after_create :start_battle!

  def start_battle!
    update!(status: :ongoing, turn: 1)
    initialize_current_hp(user_pokemon_1)
    initialize_current_hp(user_pokemon_2)
    save_both
  end

  def execute_turn!
    return if finished?

    first_attacker, second_attacker = decide_turn_order
  
    damage = calculate_damage(first_attacker, second_attacker)
    second_attacker.current_hp -= damage
    second_attacker.current_hp = 0 if second_attacker.current_hp < 0
    second_attacker.save!
  
    battle_turns.create!(
      battle: self,
      attacker: first_attacker,
      defender: second_attacker,
      damage: damage,
      turn_number: turn
    )

    if battle_over?
      update!(status: :finished, winner: first_attacker)
      return true
    end
  
    damage = calculate_damage(second_attacker, first_attacker)
    first_attacker.current_hp -= damage
    first_attacker.current_hp = 0 if first_attacker.current_hp < 0
    first_attacker.save!
  
    battle_turns.create!(
      battle: self,
      attacker: second_attacker,
      defender: first_attacker,
      damage: damage,
      turn_number: turn
    )
  
    if battle_over?
      update!(status: :finished, winner: second_attacker)
    else
      increment!(:turn)
    end
  
    true
  end

  def decide_turn_order
    if user_pokemon_1.speed >= user_pokemon_2.speed
      [user_pokemon_1, user_pokemon_2]
    else
      [user_pokemon_2, user_pokemon_1]
    end
  end

  def calculate_damage(attacker, defender)
    a = attacker.attack
    d = defender.defense
    damage = a - (d / 2)
    damage.positive? ? damage : 1
  end

  def battle_over?
    user_pokemon_1.current_hp <= 0 || user_pokemon_2.current_hp <= 0
  end

  def battle_log
    battle_turns.order(:turn_number).map do |turn|
      attacker_name = turn.attacker.pokemon.name
      defender_name = turn.defender.pokemon.name
      damage = turn.damage
      defender_hp = turn.defender.current_hp
  
      "Turn #{turn.turn_number}: #{attacker_name} attacked #{defender_name}, causing #{damage} damage. #{defender_name} has #{defender_hp} HP remaining."
    end.join("\n")
  end

  def reset_health!
    user_pokemon_1.update!(current_hp: user_pokemon_1.hp)
    user_pokemon_2.update!(current_hp: user_pokemon_2.hp)
    update!(status: :pending, turn: nil, winner: nil)
  end

  private

  def initialize_current_hp(user_pokemon)
    if user_pokemon.current_hp.nil?
      user_pokemon.current_hp = user_pokemon.hp
    end
  end

  def save_both
    user_pokemon_1.save!
    user_pokemon_2.save!
  end
end
