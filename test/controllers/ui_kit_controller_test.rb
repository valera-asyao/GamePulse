require "test_helper"

class UiKitControllerTest < ActionDispatch::IntegrationTest
  test "should get ui_kit page unauthenticated" do
    get ui_kit_url
    assert_response :success
    assert_select "h1", text: /UI Kit/
  end

  test "should get ui_kit page authenticated" do
    user = users(:one)
    post session_url, params: { email_address: user.email_address, password: "password" }
    get ui_kit_url
    assert_response :success
  end
end
