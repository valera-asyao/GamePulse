require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @genre = Genre.create!(name: "RPG", slug: "rpg")
    @game = Game.create!(title: "The Witcher 3", slug: "the-witcher-3", release_date: 5.years.ago, popularity_score: 10.0, average_rating: 9.5, ratings_count: 5)
    GameGenre.create!(game: @game, genre: @genre)
    @user = users(:one)
  end

  test "should get games catalog" do
    get root_url
    assert_response :success
    assert_select "h2", text: /Каталог видеоигр/
    assert_select "a", text: /The Witcher 3/
  end

  test "should filter games by genre" do
    get games_url(genre: "rpg")
    assert_response :success
    assert_select "a", text: /The Witcher 3/
  end

  test "should search games" do
    get games_url(q: "witcher")
    assert_response :success
    assert_select "a", text: /The Witcher 3/
  end

  test "should show game page and increment views" do
    assert_difference -> { @game.reload.views_count }, 1 do
      get game_url(@game)
      assert_response :success
      assert_select "h1", text: /The Witcher 3/
    end
  end

  test "only signed in visitors subscribe to live likes" do
    target = ActionView::RecordIdentifier.dom_id(@game, :likes_count)
    get game_url(@game)
    assert_select "strong##{target}", text: "0"
    assert_select "turbo-cable-stream-source", count: 0
    assert_select "turbo-frame", count: 0

    post session_url, params: { email_address: @user.email_address, password: "password" }
    get game_url(@game)
    assert_select "turbo-cable-stream-source[channel='Turbo::StreamsChannel']", count: 1
    assert_select "turbo-frame#game_interaction_#{@game.id} form", count: 1
  end

  test "should get recommended tab when unauthenticated" do
    get games_url(tab: "recommended")
    assert_response :success
    assert_select "h3", text: /Персональные рекомендации для вас/
  end

  test "should get recommended tab when authenticated" do
    post session_url, params: { email_address: @user.email_address, password: "password" }
    get games_url(tab: "recommended")
    assert_response :success
  end
end
