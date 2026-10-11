class Game < ApplicationRecord
  has_many :game_genres, dependent: :destroy
  has_many :genres, through: :game_genres
  has_many :game_tags, dependent: :destroy
  has_many :tags, through: :game_tags
  has_many :interactions, dependent: :destroy
  has_many :users, through: :interactions
  has_many :user_recommendations, dependent: :destroy

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  scope :popular, -> { order(popularity_score: :desc, ratings_count: :desc) }
  scope :top_rated, -> { where("ratings_count > 0").order(average_rating: :desc, ratings_count: :desc) }
  scope :recent, -> { order(release_date: :desc) }

  def to_param
    slug
  end

  def update_metrics!
    valid_ratings = interactions.where.not(rating: nil).pluck(:rating)
    count = valid_ratings.size
    avg = count > 0 ? (valid_ratings.sum.to_f / count).round(1) : 0.0

    likes_count = interactions.where(liked: true).count
    favorites_count = interactions.where(favorite: true).count

    # Popularity formula: weighted sum of views, ratings, likes, and favorites
    pop = (views_count * 0.1) + (count * 2.5) + (likes_count * 3.0) + (favorites_count * 4.0) + (avg * 1.5)

    update_columns(
      average_rating: avg,
      ratings_count: count,
      popularity_score: pop.round(2)
    )
  end

  # Find content-similar games based on shared genres and tags
  def similar_games(limit = 6)
    g_ids = genre_ids
    t_ids = tag_ids

    return Game.where.not(id: id).popular.limit(limit) if g_ids.empty? && t_ids.empty?

    Game.where.not(id: id)
        .left_joins(:game_genres, :game_tags)
        .where("game_genres.genre_id IN (?) OR game_tags.tag_id IN (?)", g_ids.presence || [ 0 ], t_ids.presence || [ 0 ])
        .group("games.id")
        .order(Arel.sql("COUNT(DISTINCT game_genres.genre_id) * 2 + COUNT(DISTINCT game_tags.tag_id) DESC, games.average_rating DESC"))
        .limit(limit)
  end

  private

  def generate_slug
    self.slug = title.parameterize if slug.blank? && title.present?
  end
end
