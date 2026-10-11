require "test_helper"

class RecommendationEngineTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @genre_rpg = Genre.create!(name: "RPG", slug: "rpg")
    @genre_action = Genre.create!(name: "Action", slug: "action")
    @genre_indie = Genre.create!(name: "Indie", slug: "indie")

    @game1 = Game.create!(title: "Witcher 3", slug: "witcher-3", release_date: 5.years.ago, popularity_score: 10.0, average_rating: 9.5, ratings_count: 5)
    @game2 = Game.create!(title: "Cyberpunk", slug: "cyberpunk", release_date: 2.years.ago, popularity_score: 8.0, average_rating: 8.8, ratings_count: 4)
    @game3 = Game.create!(title: "Hades", slug: "hades", release_date: 3.years.ago, popularity_score: 9.0, average_rating: 9.2, ratings_count: 6)

    GameGenre.create!(game: @game1, genre: @genre_rpg)
    GameGenre.create!(game: @game2, genre: @genre_rpg)
    GameGenre.create!(game: @game3, genre: @genre_indie)

    @user_a = User.create!(email_address: "user_a@test.com", username: "user_a", password: "password123")
    @user_b = User.create!(email_address: "user_b@test.com", username: "user_b", password: "password123")
  end

  test "calculates recommendations for user based on rated games" do
    # User B rates Witcher 3 (10) and Cyberpunk (9)
    Interaction.create!(user: @user_b, game: @game1, rating: 10, liked: true)
    Interaction.create!(user: @user_b, game: @game2, rating: 9, liked: true)

    # User A rates Witcher 3 (10) -> similar taste to User B!
    Interaction.create!(user: @user_a, game: @game1, rating: 10, liked: true)

    # Calculate recommendations for User A
    recs = RecommendationEngine.calculate_for(@user_a)

    assert recs.any?, "User A should receive recommendations"
    recommended_cyberpunk = recs.find { |r| r.game_id == @game2.id }
    assert_not_nil recommended_cyberpunk, "Cyberpunk should be recommended because user likes RPGs and similar user liked it"
    assert recommended_cyberpunk.score > 0, "Score should be positive"
    assert recommended_cyberpunk.reason.present?, "Should provide an explanation reason"
  end

  test "enqueues recommendation job and calculates on interaction save" do
    assert_enqueued_with(job: RecommendationJob, args: [ @user_a.id ]) do
      Interaction.create!(user: @user_a, game: @game1, rating: 10, liked: true)
    end

    perform_enqueued_jobs
    assert @user_a.user_recommendations.count > 0, "User recommendations should be saved after job completes"
  end
end
