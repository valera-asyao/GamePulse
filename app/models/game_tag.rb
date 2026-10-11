class GameTag < ApplicationRecord
  belongs_to :game
  belongs_to :tag

  validates :game_id, uniqueness: { scope: :tag_id }
end
