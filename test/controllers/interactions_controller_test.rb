require "test_helper"

class InteractionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = Game.create!(title: "Cyberpunk 2077", slug: "cyberpunk-2077")
    @user = users(:one)
  end

  test "should require login to rate a game" do
    post game_interaction_url(@game), params: {
      interaction: { rating: 10, liked: true }
    }
    assert_redirected_to new_session_url
  end

  test "should create interaction when authenticated" do
    post session_url, params: { email_address: @user.email_address, password: "password" }
    assert_redirected_to root_url

    assert_difference("Interaction.count", 1) do
      post game_interaction_url(@game), params: {
        interaction: { rating: 9, liked: true, status: "completed", hours_played: 50 }
      }
    end

    assert_redirected_to game_url(@game)
    interaction = Interaction.find_by(user: @user, game: @game)
    assert_equal 9, interaction.rating
    assert interaction.liked
  end
end
