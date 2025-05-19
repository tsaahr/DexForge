class HealingCenterController < ApplicationController
  def index
    @healing_sessions = current_user.user_pokemons.includes(:healing_session).map(&:healing_session).compact
    @available_pokemons = current_user.user_pokemons.where.not(id: @healing_sessions.map(&:user_pokemon_id))
  end

  def create
    user_pokemon = current_user.user_pokemons.find(params[:user_pokemon_id])
    return redirect_to healing_center_path, alert: "Already healing" if user_pokemon.healing_session.present?

    HealingSession.create!(
      user_pokemon: user_pokemon,
      started_at: Time.current
    )

    redirect_to healing_center_path, notice: "#{user_pokemon.name_or_nickname} is now healing!"
  end

  def collect
    session = HealingSession.find(params[:id])
    session.apply_healing!
    redirect_to healing_center_path, notice: "#{session.user_pokemon.name_or_nickname} has been healed!"
  end
end
