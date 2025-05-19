class HealingSession < ApplicationRecord
  belongs_to :user_pokemon

  def progress_percent
    return 100 if user_pokemon.current_hp >= user_pokemon.hp
  
    minutes_passed = ((Time.current - started_at) / 60).to_f
    level = user_pokemon.level || 1
  
    hp_missing = user_pokemon.hp - user_pokemon.current_hp
    total_hp = user_pokemon.hp
  
    total_healing_time = level * 2.0 * (hp_missing.to_f / total_hp)
  
    progress = (minutes_passed / total_healing_time) * 100
    progress = 100 if progress > 100
    progress.round
  end
  

  def seconds_left
    return 0 if progress_percent >= 100
  
    level = user_pokemon.level || 1
    total_seconds = level * 2 * 60
    elapsed = Time.current - started_at
    remaining = total_seconds - elapsed
    remaining.positive? ? remaining.to_i : 0
  end

  def remaining_seconds
    return 0 if user_pokemon.current_hp >= user_pokemon.hp
  
    level = user_pokemon.level || 1
    hp_missing = user_pokemon.hp - user_pokemon.current_hp
    total_hp = user_pokemon.hp
  
    total_minutes = level * 2.0 * (hp_missing.to_f / total_hp)
    elapsed = ((Time.current - started_at) / 60.0)
  
    remaining = (total_minutes - elapsed) * 60 
    remaining = 0 if remaining < 0
  
    remaining.round
  end
  

  def apply_healing!
    return if progress_percent < 100

    user_pokemon.current_hp = user_pokemon.hp
    user_pokemon.save!
    destroy
  end
end
