namespace :moves_type do
  desc "Associar os moves ao model Type com base no move_type string antigo"
  task assign_types: :environment do
    Move.find_each do |move|
      if move.respond_to?(:move_type) && move.move_type.present?
        type = Type.find_by("LOWER(name) = ?", move.move_type.strip.downcase)
        if type
          move.update!(type: type)
          puts "✔️  #{move.name} => #{type.name}"
        else
          puts "❌ Tipo '#{move.move_type}' não encontrado para move #{move.name}"
        end
      else
        puts "⚠️  Move #{move.name} não possui move_type definido"
      end
    end

    puts "✅ Todos os moves foram processados."
  end
end
