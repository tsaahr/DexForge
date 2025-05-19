class CaptureController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_starter_chosen
  
  def index
  end

  def encounter
    wild_level = rand(5..40)
    base_pokemon = Pokemon.where(evolves_from: nil, is_legendary: false, is_mythical: false).sample
    evolved = rand < 0.2 ? base_pokemon.auto_evolve_for_level!(wild_level) : base_pokemon
  
    @wild_pokemon = WildPokemon.build_with_best_moves(pokemon: evolved, level: wild_level)
    @wild_pokemon.save!
  end

  def start_battle
    @wild_pokemon = WildPokemon.find(params[:id])
    @user_pokemon = current_user.user_pokemons.first
  
    @wild_battle = WildBattle.create!(
      user_pokemon: @user_pokemon,
      wild_pokemon: @wild_pokemon
    )
  
    redirect_to wild_battle_path(@wild_battle)
  end  

  def started?
    battle_logs.exists?
  end

  def next_turn_battle
    @wild_battle = WildBattle.find(params[:id])
  
    user_pokemon = @wild_battle.user_pokemon
    wild_pokemon = @wild_battle.wild_pokemon
  
    attacker_move = user_pokemon.moves.sample
    defender_move = wild_pokemon.moves.sample
  
    BattleEngine.new(
      @wild_battle,
      attacker_move: attacker_move,
      defender_move: defender_move,
      attacker: user_pokemon,
      defender: wild_pokemon
    ).execute_turn!
  
    redirect_to capture_battle_path(wild_pokemon)
  end
  

  def throw_pokeball
    battle = WildBattle.find(params[:id])
  
    unless battle.started?
      return render json: { error: "Battle not started" }, status: :unprocessable_entity
    end
  
    if battle.finished?
      return render json: { error: "Battle already finished" }, status: :unprocessable_entity
    end
  
    chance = battle.capture_chance / 100.0
    success = rand < chance

    if success
      current_user.user_pokemons.create!(
        pokemon: battle.wild_pokemon.pokemon,
        wild_pokemon: battle.wild_pokemon,
        level: battle.wild_pokemon.level,
        experience: 0,
    
        hp_iv: battle.wild_pokemon.hp_iv,
        attack_iv: battle.wild_pokemon.attack_iv,
        defense_iv: battle.wild_pokemon.defense_iv,
        sp_attack_iv: battle.wild_pokemon.sp_attack_iv,
        sp_defense_iv: battle.wild_pokemon.sp_defense_iv,
        speed_iv: battle.wild_pokemon.speed_iv,
    
        hp: battle.wild_pokemon.hp,
        current_hp: battle.wild_pokemon.current_hp,
        attack: battle.wild_pokemon.attack,
        defense: battle.wild_pokemon.defense,
        sp_attack: battle.wild_pokemon.sp_attack,
        sp_defense: battle.wild_pokemon.sp_defense,
        speed: battle.wild_pokemon.speed
      )
      battle.update!(status: :finished, winner: current_user)
      render json: { captured: true }
    else
      battle.update!(status: :finished)
      render json: { captured: false }
    end
  end
  
  
  
  def show
    @wild_pokemon = WildPokemon.find(params[:id])
    @all_moves = @wild_pokemon.all_possible_moves
  end
  def battle
    @user_pokemon = current_user.user_pokemons.find_by(selected: true)

    unless @user_pokemon
      redirect_back fallback_location: capture_encounter_path, alert: "You need to select a Pokémon before battling."
      return
    end
  
    @wild_pokemon = WildPokemon.find(params[:id])
    @wild_pokemon = WildPokemon.find(params[:id])
    @user_pokemon = current_user.user_pokemons.find_by(selected: true)
  
    @wild_battle = WildBattle.find_or_create_by!(
      user_pokemon: @user_pokemon,
      wild_pokemon: @wild_pokemon
    ) do |battle|
      battle.current_turn = "user"
      battle.stat_stages = {
        @user_pokemon.id.to_s => battle.base_stage_hash,
        @wild_pokemon.id.to_s => battle.base_stage_hash

      }
    end

    @battle_logs = @wild_battle.battle_logs.order(:turn)
  end
  
end
