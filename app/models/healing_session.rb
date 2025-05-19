class HealingSession < ApplicationRecord
  belongs_to :user_pokemon

  def progress_percent
    return 100 if user_pokemon.current_hp >= user_pokemon.hp

    minutes_passed = ((Time.current - started_at) / 60).to_i
    healing_rate = user_pokemon.current_hp <= 0 ? 100.0 / 120 : 10

    progress = (minutes_passed * healing_rate)
    progress = 100 if progress > 100
    progress
  end

  def apply_healing!
    return if progress_percent < 100

    user_pokemon.current_hp = user_pokemon.hp
    user_pokemon.save!
    destroy
  end
end
