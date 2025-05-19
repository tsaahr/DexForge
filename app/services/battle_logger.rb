class BattleLogger
  def initialize(battle)
    @battle = battle
  end

  def log_attack(attacker:, move:, defender:, damage:, super_effective: false, fainted: false, turn:)

    last_turn = @battle.battle_logs.maximum(:turn) || 0
    turn = last_turn + 1

    msg = "#{attacker.pokemon.name} used #{move['name']} on #{defender.pokemon.name}. "
    msg += "It was super effective! " if super_effective
    msg += "#{defender.pokemon.name} took #{damage} damage. "
    msg += "#{defender.pokemon.name} fainted!" if fainted

    BattleLog.create!(
      battleable: @battle,
      message: msg,
      turn: turn
    )
  end
end
