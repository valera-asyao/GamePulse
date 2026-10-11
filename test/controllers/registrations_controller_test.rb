require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new registration form" do
    get new_registration_url
    assert_response :success
    assert_select "h1", "Создать аккаунт"
  end

  test "should register a new user and log them in" do
    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: {
          email_address: "new_player@test.com",
          username: "new_player",
          name: "Новый Игрок",
          password: "secure_password",
          password_confirmation: "secure_password",
          bio: "Любитель RPG"
        }
      }
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_select "header", text: /Новый Игрок|new_player/
  end

  test "should reject invalid registration" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: "invalid_email",
          username: "ab",
          password: "123",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".list-disc"
  end
end
