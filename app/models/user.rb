class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :interactions, dependent: :destroy
  has_many :interacted_games, through: :interactions, source: :game
  has_many :user_recommendations, -> { order(score: :desc) }, dependent: :destroy
  has_many :recommended_games, through: :user_recommendations, source: :game

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(u) { u.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "может содержать только латинские буквы, цифры и знак подчеркивания" }
  validates :password, length: { minimum: 3 }, if: -> { new_record? || !password.nil? }

  has_one_attached :avatar

  PRESET_AVATARS = [
    { id: "cyberpunk", name: "Киберпанк", url: "https://api.dicebear.com/7.x/bottts/svg?seed=cyberpunk&backgroundColor=b6e3f4" },
    { id: "warrior", name: "Воин", url: "https://api.dicebear.com/7.x/adventurer/svg?seed=Felix&backgroundColor=ffd5dc" },
    { id: "mage", name: "Маг", url: "https://api.dicebear.com/7.x/adventurer/svg?seed=Shadow&backgroundColor=d1d4f9" },
    { id: "rogue", name: "Ассасин", url: "https://api.dicebear.com/7.x/adventurer/svg?seed=Bandit&backgroundColor=c0aede" },
    { id: "pilot", name: "Пилот Мехи", url: "https://api.dicebear.com/7.x/bottts/svg?seed=mech&backgroundColor=ffdfbf" },
    { id: "pixel", name: "Пиксельный Герой", url: "https://api.dicebear.com/7.x/pixel-art/svg?seed=hero" },
    { id: "sorceress", name: "Чародейка", url: "https://api.dicebear.com/7.x/adventurer/svg?seed=Zoe&backgroundColor=ffd5dc" },
    { id: "retro", name: "Ретро Геймер", url: "https://api.dicebear.com/7.x/pixel-art/svg?seed=gamer" }
  ].freeze

  def display_name
    name.presence || username
  end

  def avatar_image_url
    if avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: true)
    elsif avatar_url.present?
      avatar_url
    else
      nil
    end
  end

  # Helper to get user's favorite genres based on interactions and high ratings
  def favorite_genres
    Genre.joins(game_genres: { game: :interactions })
         .where(interactions: { user_id: id })
         .where("interactions.rating >= 7 OR interactions.liked = ?", true)
         .group("genres.id")
         .order("COUNT(interactions.id) DESC")
  end

  def interaction_for(game)
    interactions.find_by(game_id: game.id)
  end
end
