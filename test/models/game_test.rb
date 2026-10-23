require "test_helper"

class GameTest < ActiveSupport::TestCase
  setup do
    @rpg = Genre.create!(name: "RPG Test", slug: "rpg-test")
    @action = Genre.create!(name: "Action Test", slug: "action-test")
    @open_world = Tag.create!(name: "Open World Test", slug: "open-world-test")

    @game = Game.create!(
      title: "Witcher 3 Test",
      slug: "witcher-3-test",
      release_date: Date.new(2015, 5, 19),
      views_count: 500
    )
    @user1 = User.create!(email_address: "gametest1@test.com", username: "gametest1", password: "password123")
    @user2 = User.create!(email_address: "gametest2@test.com", username: "gametest2", password: "password123")
  end

  # Context 1: Business Logic - update_metrics!
  test "update_metrics! recalculates average rating, ratings count, and popularity score" do
    Interaction.create!(user: @user1, game: @game, rating: 10, liked: true, favorite: true)
    Interaction.create!(user: @user2, game: @game, rating: 8, liked: true, favorite: false)

    @game.update_metrics!
    @game.reload

    assert_equal 2, @game.ratings_count
    assert_equal 9.0, @game.average_rating
    # pop = (views_count * 0.1) + (count * 2.5) + (likes_count * 3.0) + (favorites_count * 4.0) + (avg * 1.5)
    # pop = (500 * 0.1) + (2 * 2.5) + (2 * 3.0) + (1 * 4.0) + (9.0 * 1.5) = 50 + 5 + 6 + 4 + 13.5 = 78.5
    assert_in_delta 78.5, @game.popularity_score, 0.1
  end

  test "update_metrics! handles games with zero ratings gracefully" do
    @game.update_metrics!
    @game.reload

    assert_equal 0, @game.ratings_count
    assert_equal 0.0, @game.average_rating
    assert_equal 50.0, @game.popularity_score
  end

  # Context 2: Business Logic - similar_games
  test "similar_games returns games sharing genres and tags ordered by relevance" do
    GameGenre.create!(game: @game, genre: @rpg)
    GameGenre.create!(game: @game, genre: @action)
    GameTag.create!(game: @game, tag: @open_world)

    game_matching = Game.create!(title: "Cyberpunk Test", slug: "cyberpunk-test", average_rating: 9.0)
    GameGenre.create!(game: game_matching, genre: @rpg)
    GameTag.create!(game: game_matching, tag: @open_world)

    game_unrelated = Game.create!(title: "Sims Test", slug: "sims-test", average_rating: 6.0)

    results = @game.similar_games(5)

    assert_includes results, game_matching
    assert_not_includes results, @game, "similar_games should exclude self"
    assert_equal game_matching.id, results.first.id
  end

  # Context 3: Validations, Slugs, and Scopes
  test "validates title presence and slug uniqueness" do
    invalid = Game.new(title: "")
    assert_not invalid.valid?
    assert_includes invalid.errors[:title], "can't be blank"

    duplicate = Game.new(title: "Another Game", slug: @game.slug)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "auto-generates slug from title if blank and uses slug in to_param" do
    new_game = Game.create!(title: "Grand Theft Auto VI")
    assert_equal "grand-theft-auto-vi", new_game.slug
    assert_equal new_game.slug, new_game.to_param
  end

  test "scopes filter by popularity, top_rated, and release recency" do
    g_top = Game.create!(title: "Top Hit", slug: "top-hit", average_rating: 9.9, ratings_count: 5, popularity_score: 100.0, release_date: 1.month.ago)
    g_old = Game.create!(title: "Old Game", slug: "old-game", average_rating: 6.0, ratings_count: 1, popularity_score: 5.0, release_date: 10.years.ago)

    assert_equal g_top, Game.popular.first
    assert_equal g_top, Game.top_rated.first
    assert_equal g_top, Game.recent.first
  end
end
