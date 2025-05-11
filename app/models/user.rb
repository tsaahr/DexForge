class User < ApplicationRecord
  has_many :user_pokemon
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable
  
end
