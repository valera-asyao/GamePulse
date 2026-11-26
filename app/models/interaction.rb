class Interaction < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :user_id, uniqueness: { scope: :game_id }
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true
  validates :hours_played, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 30_000 }, allow_nil: true

  STATUSES = %w[none want_to_play playing completed dropped].freeze
  validates :status, inclusion: { in: STATUSES }, allow_nil: true

  after_save :refresh_metrics_and_recommendations
  after_destroy :refresh_metrics_and_recommendations
  after_commit :broadcast_likes_count, if: :likes_count_changed?

  private

  def likes_count_changed?
    destroyed? ? liked? : saved_change_to_liked?
  end

  def broadcast_likes_count
    Turbo::StreamsChannel.broadcast_replace_to(
      game, :likes,
      target: ActionView::RecordIdentifier.dom_id(game, :likes_count),
      partial: "games/likes_count",
      locals: { game: game }
    )
  end

  def refresh_metrics_and_recommendations
    game.update_metrics!
    # Recalculate recommendations in the background / queue
    RecommendationJob.perform_later(user_id) if user_id.present?
  end
end
