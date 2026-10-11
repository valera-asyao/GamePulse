class UserRecommendation < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :user_id, uniqueness: { scope: :game_id }
  validates :score, presence: true

  scope :top_picks, -> { order(score: :desc) }
end
