require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email_address: "gamerexpert@test.com",
      username: "gamerexpert",
      name: "Alex Gamer",
      password: "password123"
    )
  end

  # Context 1: Business Logic - favorite_genres and interaction_for
  test "favorite_genres returns user top genres based on high ratings and likes" do
    rpg = Genre.create!(name: "RPG User Test", slug: "rpg-user-test")
    strategy = Genre.create!(name: "Strategy User Test", slug: "strat-user-test")

    game1 = Game.create!(title: "RPG Game 1", slug: "rpg-game-1")
    game2 = Game.create!(title: "RPG Game 2", slug: "rpg-game-2")
    game3 = Game.create!(title: "Strategy Game", slug: "strat-game")

    GameGenre.create!(game: game1, genre: rpg)
    GameGenre.create!(game: game2, genre: rpg)
    GameGenre.create!(game: game3, genre: strategy)

    # User rates both RPG games highly (>= 7)
    Interaction.create!(user: @user, game: game1, rating: 9)
    Interaction.create!(user: @user, game: game2, rating: 8)
    # User rates strategy game low
    Interaction.create!(user: @user, game: game3, rating: 4)

    favs = @user.favorite_genres
    assert_includes favs, rpg
    assert_not_includes favs, strategy, "Low-rated genres (<7 without like) should not be favorite"
    assert_equal rpg.id, favs.first.id
  end

  test "interaction_for finds interaction for a specific game" do
    game = Game.create!(title: "Lookup Game", slug: "lookup-game")
    interaction = Interaction.create!(user: @user, game: game, rating: 10)

    found = @user.interaction_for(game)
    assert_equal interaction.id, found.id

    unrated_game = Game.create!(title: "Unrated Game", slug: "unrated-game")
    assert_nil @user.interaction_for(unrated_game)
  end

  # Context 2: Business Logic - display_name and avatar_image_url
  test "display_name returns name if present, otherwise falls back to username" do
    assert_equal "Alex Gamer", @user.display_name

    user_without_name = User.new(username: "solo_player", email_address: "solo@test.com")
    assert_equal "solo_player", user_without_name.display_name
  end

  test "avatar_image_url resolves preset avatar_url when no active storage attachment" do
    assert_nil @user.avatar_image_url

    @user.update!(avatar_url: "https://api.dicebear.com/7.x/bottts/svg?seed=cyberpunk")
    assert_equal "https://api.dicebear.com/7.x/bottts/svg?seed=cyberpunk", @user.avatar_image_url
  end

  # Context 3: Validations & Normalizations
  test "downcases and strips email_address and username" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ", username: " NEW_USER ")
    assert_equal "downcased@example.com", user.email_address
    assert_equal "new_user", user.username
  end

  test "validates username format and length constraints" do
    invalid_chars = User.new(username: "bad user!", email_address: "bad@test.com", password: "password")
    assert_not invalid_chars.valid?
    assert_includes invalid_chars.errors[:username], "может содержать только латинские буквы, цифры и знак подчеркивания"

    too_short = User.new(username: "ab", email_address: "short@test.com", password: "password")
    assert_not too_short.valid?
    assert_includes too_short.errors[:username], "is too short (minimum is 3 characters)"
  end
end
