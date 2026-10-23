require "test_helper"

class RecommendationEngineTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @genre_rpg = Genre.create!(name: "RPG Rec Test", slug: "rpg-rec-test")
    @genre_action = Genre.create!(name: "Action Rec Test", slug: "action-rec-test")
    @genre_indie = Genre.create!(name: "Indie Rec Test", slug: "indie-rec-test")

    @game1 = Game.create!(title: "Witcher 3 Rec", slug: "witcher-3-rec", release_date: 5.years.ago, popularity_score: 10.0, average_rating: 9.5, ratings_count: 5)
    @game2 = Game.create!(title: "Cyberpunk Rec", slug: "cyberpunk-rec", release_date: 2.years.ago, popularity_score: 8.0, average_rating: 8.8, ratings_count: 4)
    @game3 = Game.create!(title: "Hades Rec", slug: "hades-rec", release_date: 3.years.ago, popularity_score: 9.0, average_rating: 9.2, ratings_count: 6)

    GameGenre.create!(game: @game1, genre: @genre_rpg)
    GameGenre.create!(game: @game2, genre: @genre_rpg)
    GameGenre.create!(game: @game3, genre: @genre_indie)

    @user_a = User.create!(email_address: "usera_rec@test.com", username: "user_a_rec", password: "password123")
    @user_b = User.create!(email_address: "userb_rec@test.com", username: "user_b_rec", password: "password123")
    @user_cold = User.create!(email_address: "usercold_rec@test.com", username: "user_cold_rec", password: "password123")
  end

  # Context 1: Personalized Hybrid Recommendations
  test "calculates recommendations for user based on rated games and similar users" do
    Interaction.create!(user: @user_b, game: @game1, rating: 10, liked: true)
    Interaction.create!(user: @user_b, game: @game2, rating: 9, liked: true)

    # User A also likes Witcher 3
    Interaction.create!(user: @user_a, game: @game1, rating: 10, liked: true)

    recs = RecommendationEngine.calculate_for(@user_a)

    assert recs.any?, "User A should receive recommendations"
    recommended_cyberpunk = recs.find { |r| r.game_id == @game2.id }
    assert_not_nil recommended_cyberpunk, "Cyberpunk should be recommended because user likes RPGs and similar user liked it"
    assert recommended_cyberpunk.score > 0, "Score should be positive"
    assert recommended_cyberpunk.reason.present?, "Should provide an explanation reason"
  end

  # Context 2: Asynchronous Job Enqueueing
  test "enqueues recommendation job and calculates on interaction save" do
    assert_enqueued_with(job: RecommendationJob, args: [ @user_a.id ]) do
      Interaction.create!(user: @user_a, game: @game1, rating: 10, liked: true)
    end

    perform_enqueued_jobs
    assert @user_a.user_recommendations.count > 0, "User recommendations should be saved after job completes"
  end

  # Context 3: Cold Start Strategy
  test "handles cold start for new users with zero interactions using catalog quality and popularity" do
    assert_equal 0, @user_cold.interactions.count

    recs = RecommendationEngine.calculate_for(@user_cold)

    assert recs.any?, "Cold start user should still receive top candidate recommendations"
    top_rec = recs.first
    assert top_rec.score > 0, "Cold start score should be positive"
    assert top_rec.reason.present?, "Cold start recommendation should explain why"
  end
end
