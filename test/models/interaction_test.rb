require "test_helper"
require "turbo/broadcastable/test_helper"

class InteractionTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  setup do
    @user = User.create!(email_address: "interuser@test.com", username: "interuser", password: "password123")
    @game = Game.create!(title: "Metrics Test Game", slug: "metrics-test-game", views_count: 100)
  end

  # Context 1: Business Logic - Automated Metric Refresh & Recommendation Enqueueing
  test "creating an interaction immediately refreshes game metrics and queues recommendation job" do
    assert_enqueued_with(job: RecommendationJob, args: [@user.id]) do
      Interaction.create!(user: @user, game: @game, rating: 9, liked: true)
    end

    @game.reload
    assert_equal 1, @game.ratings_count
    assert_equal 9.0, @game.average_rating
  end

  test "destroying an interaction recalculates game metrics" do
    interaction = Interaction.create!(user: @user, game: @game, rating: 8)
    @game.reload
    assert_equal 1, @game.ratings_count

    interaction.destroy
    @game.reload
    assert_equal 0, @game.ratings_count
    assert_equal 0.0, @game.average_rating
  end

  test "changing a like broadcasts the current count for its game" do
    other_game = Game.create!(title: "Another Game")
    assert_no_turbo_stream_broadcasts [ other_game, :likes ] do
      assert_turbo_stream_broadcasts [ @game, :likes ], count: 1 do
        @interaction = Interaction.create!(user: @user, game: @game, liked: true)
      end
    end

    assert_turbo_stream_broadcasts [ @game, :likes ], count: 0 do
      @interaction.update!(rating: 8)
    end

    target = ActionView::RecordIdentifier.dom_id(@game, :likes_count)
    streams = capture_turbo_stream_broadcasts([ @game, :likes ]) do
      @interaction.update!(liked: false)
      @interaction.update!(liked: true)
      @interaction.destroy!
    end

    assert_equal %w[0 1 0], streams.map { |stream| stream.at_css("strong##{target}").text }
    assert streams.all? { |stream| stream["action"] == "replace" && stream["target"] == target }
  end

  # Context 2: Validations & Business Constraints
  test "validates rating is an integer between 1 and 10" do
    assert Interaction.new(user: @user, game: @game, rating: 10).valid?
    assert Interaction.new(user: @user, game: @game, rating: 1).valid?

    low = Interaction.new(user: @user, game: @game, rating: 0)
    assert_not low.valid?
    assert_includes low.errors[:rating], "must be greater than or equal to 1"

    high = Interaction.new(user: @user, game: @game, rating: 11)
    assert_not high.valid?
    assert_includes high.errors[:rating], "must be less than or equal to 10"
  end

  test "validates one interaction per user and game combination" do
    Interaction.create!(user: @user, game: @game, rating: 7)
    duplicate = Interaction.new(user: @user, game: @game, rating: 9)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "validates status inclusion in allowed list" do
    assert Interaction.new(user: @user, game: @game, status: "completed").valid?
    assert Interaction.new(user: @user, game: @game, status: "want_to_play").valid?

    invalid = Interaction.new(user: @user, game: @game, status: "unknown_status")
    assert_not invalid.valid?
    assert_includes invalid.errors[:status], "is not included in the list"
  end
end
