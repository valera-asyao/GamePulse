require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  setup do
    @genre = Genre.create!(name: "RPG", slug: "rpg")
    @game = Game.create!(title: "The Witcher 3", slug: "the-witcher-3",
                         release_date: 5.years.ago, popularity_score: 10.0,
                         average_rating: 9.5, ratings_count: 5)
    GameGenre.create!(game: @game, genre: @genre)
    @user = users(:one)
  end

  # Happy path: регистрация -> каталог -> страница игры -> оценка -> рекомендации -> профиль
  test "happy path: регистрация, оценка игры, рекомендации и профиль" do
    get new_registration_url
    assert_response :success

    assert_difference("User.count", 1) do
      post registration_url, params: { user: {
        email_address: "gamer@example.com",
        username: "gamer",
        name: "Геймер",
        password: "secret",
        password_confirmation: "secret"
      } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_response :success

    get games_url
    assert_response :success
    assert_select "a", text: /The Witcher 3/

    get game_url(@game)
    assert_response :success
    assert_select "h1", text: /The Witcher 3/

    assert_difference("Interaction.count", 1) do
      post game_interaction_url(@game), params: {
        interaction: { rating: 9, liked: true, status: "completed", hours_played: 120 }
      }
    end
    assert_redirected_to game_url(@game)

    get recommendations_url
    assert_response :success

    get profile_url
    assert_response :success

    patch profile_url, params: { user: { name: "Геймер Про", bio: "Люблю RPG" } }
    assert_redirected_to profile_url
    assert_equal "Геймер Про", User.find_by(username: "gamer").name

    delete session_url
    assert_redirected_to new_session_url
  end

  # Ответвление 1: неверный пароль при входе — ошибка, сессия не создаётся
  test "вход с неверным паролем показывает ошибку" do
    assert_no_difference("Session.count") do
      post session_url, params: { email_address: @user.email_address, password: "wrong-password" }
    end
    assert_redirected_to new_session_url
    follow_redirect!
    assert_match "Неверный адрес электронной почты или пароль", response.body

    get profile_url
    assert_redirected_to new_session_url
  end

  # Ответвление 2: гость без авторизации пытается оценить игру / открыть рекомендации — отказ
  test "гость не может оценивать игры и смотреть рекомендации" do
    assert_no_difference("Interaction.count") do
      post game_interaction_url(@game), params: { interaction: { rating: 10, liked: true } }
    end
    assert_redirected_to new_session_url

    get recommendations_url
    assert_redirected_to new_session_url

    get profile_url
    assert_redirected_to new_session_url
  end

  # Ответвление 3: регистрация с невалидными данными — форма с ошибкой, пользователь не создаётся
  test "регистрация с невалидными данными выдаёт ошибку" do
    assert_no_difference("User.count") do
      post registration_url, params: { user: {
        email_address: "not-an-email",
        username: "x",
        password: "secret",
        password_confirmation: "secret"
      } }
    end
    assert_response :unprocessable_entity

    assert_no_difference("User.count") do
      post registration_url, params: { user: {
        email_address: @user.email_address,
        username: "validname",
        password: "secret",
        password_confirmation: "secret"
      } }
    end
    assert_response :unprocessable_entity
  end

  # Ответвление 4: невалидная оценка игры — ошибка, взаимодействие не сохраняется
  test "оценка вне диапазона отклоняется" do
    sign_in_as @user

    assert_no_difference("Interaction.count") do
      post game_interaction_url(@game), params: { interaction: { rating: 99 } }
    end
    assert_redirected_to game_url(@game)
    follow_redirect!
    assert_match "Не удалось сохранить изменения", response.body
  end
end
