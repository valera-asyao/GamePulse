class Interaction < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :user_id, uniqueness: { scope: :game_id }
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true
  validates :hours_played, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  STATUSES = %w[none want_to_play playing completed dropped].freeze
  validates :status, inclusion: { in: STATUSES }, allow_nil: true

  after_save :refresh_metrics_and_recommendations
  after_destroy :refresh_metrics_and_recommendations

  private

  def refresh_metrics_and_recommendations
    game.update_metrics!
    # Recalculate recommendations in the background / queue
    RecommendationJob.perform_later(user_id) if user_id.present?
  end
end
