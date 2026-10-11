class RecommendationEngine
  WEIGHT_GENRES        = 0.4
  WEIGHT_COLLABORATIVE = 0.3
  WEIGHT_POPULARITY    = 0.2
  WEIGHT_RECENCY       = 0.1

  def self.calculate_for(user)
    new(user).calculate!
  end

  def initialize(user)
    @user = user
  end

  def calculate!
    return [] unless @user

    # Fetch user interactions
    user_interactions = @user.interactions.includes(:game).to_a
    interacted_game_ids = user_interactions.map(&:game_id)

    # Candidate games: all games except ones user has already strongly interacted with (unless wishlist)
    excluded_ids = user_interactions.select { |i| i.rating.present? || i.status == "completed" }.map(&:game_id)
    candidates = Game.includes(:genres, :tags).where.not(id: excluded_ids).to_a

    return [] if candidates.empty?

    # Precompute user profile vectors
    user_genre_weights = compute_user_genre_preferences(user_interactions)
    user_tag_weights   = compute_user_tag_preferences(user_interactions)

    # Precompute collaborative similarity matrix
    user_similarities = compute_user_similarities(user_interactions)

    # Max popularity in candidate pool for normalization
    max_popularity = [candidates.map(&:popularity_score).max.to_f, 1.0].max
    now = Date.current

    recommendations = []

    candidates.each do |game|
      # 1. Content / Genre & Tag score (0.0 .. 1.0)
      genre_score, matched_genres = compute_content_score(game, user_genre_weights, user_tag_weights)

      # 2. Collaborative filtering score (0.0 .. 1.0)
      collab_score, collab_details = compute_collaborative_score(game, user_similarities)

      # 3. Popularity score (0.0 .. 1.0)
      pop_score = [(game.popularity_score / max_popularity).clamp(0.0, 1.0), 0.0].max

      # 4. Recency / Freshness score (0.0 .. 1.0)
      recency_score = compute_recency_score(game, now)

      # Combined Final Weighted Rating (Formula from architecture spec)
      final_score = (
        (genre_score   * WEIGHT_GENRES) +
        (collab_score  * WEIGHT_COLLABORATIVE) +
        (pop_score     * WEIGHT_POPULARITY) +
        (recency_score * WEIGHT_RECENCY)
      ).round(4)

      # Generate explanation reason
      reason = build_explanation(game, genre_score, collab_score, pop_score, matched_genres, collab_details)

      recommendations << {
        user_id: @user.id,
        game_id: game.id,
        score: final_score,
        genre_score: genre_score.round(3),
        collaborative_score: collab_score.round(3),
        popularity_score: pop_score.round(3),
        recency_score: recency_score.round(3),
        reason: reason,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    # Save to database (upsert/replace)
    ActiveRecord::Base.transaction do
      UserRecommendation.where(user_id: @user.id).delete_all
      if recommendations.any?
        # Sort and take top 30
        top_recommendations = recommendations.sort_by { |r| -r[:score] }.first(30)
        UserRecommendation.insert_all(top_recommendations)
      end
    end

    # Invalidate / warm cache
    cache_key = "user:#{@user.id}:recommendations"
    Rails.cache.write(cache_key, @user.user_recommendations.includes(game: [:genres, :tags]).to_a, expires_in: 2.hours)

    @user.user_recommendations.includes(game: [:genres, :tags])
  end

  private

  # Calculate genre preferences based on ratings and likes
  def compute_user_genre_preferences(interactions)
    weights = Hash.new(0.0)
    interactions.each do |interaction|
      # Base multiplier from rating or interaction
      multiplier = if interaction.rating.present?
                     (interaction.rating - 5.0) / 5.0 # -0.8 to +1.0
                   elsif interaction.liked || interaction.favorite
                     0.8
                   else
                     0.2
                   end
      multiplier += 0.3 if interaction.favorite
      multiplier += 0.2 if interaction.liked

      interaction.game.game_genres.each do |gg|
        weights[gg.genre_id] += multiplier
      end
    end
    weights
  end

  def compute_user_tag_preferences(interactions)
    weights = Hash.new(0.0)
    interactions.each do |interaction|
      multiplier = interaction.rating.present? ? (interaction.rating - 5.0) / 5.0 : 0.4
      interaction.game.game_tags.each do |gt|
        weights[gt.tag_id] += multiplier
      end
    end
    weights
  end

  # Compare target user with other users via Cosine similarity on shared ratings
  def compute_user_similarities(interactions)
    my_ratings = interactions.select { |i| i.rating.present? }
    return {} if my_ratings.empty?

    my_ratings_map = my_ratings.to_h { |i| [i.game_id, i.rating] }
    common_games = my_ratings_map.keys

    # Find other users who rated at least one common game
    other_interactions = Interaction.where(game_id: common_games)
                                    .where.not(user_id: @user.id)
                                    .where.not(rating: nil)
                                    .group_by(&:user_id)

    similarities = {}
    other_interactions.each do |other_user_id, o_ints|
      o_ratings_map = o_ints.to_h { |i| [i.game_id, i.rating] }

      shared_keys = common_games & o_ratings_map.keys
      next if shared_keys.empty?

      # Cosine similarity
      dot = shared_keys.sum { |k| my_ratings_map[k] * o_ratings_map[k] }
      norm_a = Math.sqrt(shared_keys.sum { |k| my_ratings_map[k]**2 })
      norm_b = Math.sqrt(shared_keys.sum { |k| o_ratings_map[k]**2 })

      if norm_a > 0 && norm_b > 0
        similarity = dot / (norm_a * norm_b)
        similarities[other_user_id] = similarity if similarity > 0.1
      end
    end

    similarities
  end

  def compute_content_score(game, user_genre_weights, user_tag_weights)
    if user_genre_weights.empty? && user_tag_weights.empty?
      # Cold start: fallback to game's own normalized quality
      return [(game.average_rating / 10.0), []]
    end

    matched_genres = []
    genre_score = 0.0

    game.game_genres.each do |gg|
      w = user_genre_weights[gg.genre_id]
      if w && w > 0
        genre_score += w
        matched_genres << gg.genre.name rescue nil
      end
    end

    tag_score = 0.0
    game.game_tags.each do |gt|
      w = user_tag_weights[gt.tag_id]
      tag_score += w if w && w > 0
    end

    # Normalize roughly to 0..1 scale
    total_raw = (genre_score * 0.7) + (tag_score * 0.3)
    normalized = (total_raw / 3.0).clamp(0.0, 1.0)
    [normalized, matched_genres.compact.uniq]
  end

  def compute_collaborative_score(game, user_similarities)
    if user_similarities.empty?
      # Fallback to normalized average rating
      return [(game.average_rating / 10.0), { similar_users_count: 0 }]
    end

    # Find ratings of this game by similar users
    neighbor_ratings = Interaction.where(game_id: game.id, user_id: user_similarities.keys)
                                  .where.not(rating: nil)

    if neighbor_ratings.empty?
      # Fallback to general rating
      return [(game.average_rating / 10.0) * 0.8, { similar_users_count: 0 }]
    end

    weighted_sum = 0.0
    weights_sum = 0.0

    neighbor_ratings.each do |nr|
      sim = user_similarities[nr.user_id]
      weighted_sum += sim * nr.rating
      weights_sum += sim
    end

    predicted_rating = weights_sum > 0 ? (weighted_sum / weights_sum) : game.average_rating
    normalized = (predicted_rating / 10.0).clamp(0.0, 1.0)

    [normalized, { similar_users_count: neighbor_ratings.count, predicted_rating: predicted_rating.round(1) }]
  end

  def compute_recency_score(game, current_date)
    return 0.5 unless game.release_date

    years_ago = (current_date - game.release_date).to_f / 365.25
    if years_ago <= 0.5
      1.0
    elsif years_ago <= 1.5
      0.9
    elsif years_ago <= 3.0
      0.75
    elsif years_ago <= 6.0
      0.55
    else
      [0.3, 0.9 - (years_ago * 0.05)].max
    end
  end

  def build_explanation(game, genre_score, collab_score, pop_score, matched_genres, collab_details)
    reasons = []

    if matched_genres.any? && genre_score > 0.4
      reasons << "Подходит под ваш интерес к жанрам: #{matched_genres.first(2).join(', ')}"
    end

    if collab_details[:similar_users_count] && collab_details[:similar_users_count] > 0
      reasons << "Высоко оценено пользователями с похожими вкусами (~#{collab_details[:predicted_rating]}/10)"
    end

    if pop_score > 0.7
      reasons << "Популярный хит среди игроков"
    end

    if reasons.empty?
      if game.average_rating >= 8.5
        reasons << "Шедевр с высоким средним рейтингом (#{game.average_rating}/10)"
      else
        reasons << "Рекомендовано на основе гибридного анализа каталога"
      end
    end

    reasons.join(". ")
  end
end
