class HealingSession < ApplicationRecord
  belongs_to :user_pokemon

  def progress_percent
    return 100 if user_pokemon.current_hp >= user_pokemon.hp
  
    minutes_passed = ((Time.current - started_at) / 60).to_i
    level = user_pokemon.level || 1
    total_minutes_to_heal = level * 2
  
    progress = (minutes_passed.to_f / total_minutes_to_heal) * 100
    progress = 100 if progress > 100
    progress.round
  end
  

  def apply_healing!
    return if progress_percent < 100

    user_pokemon.current_hp = user_pokemon.hp
    user_pokemon.save!
    destroy
  end
end
