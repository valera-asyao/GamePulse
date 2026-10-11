require "application_system_test_case"

class HomepageTest < ApplicationSystemTestCase
  test "visiting the homepage loads successfully" do
    visit root_url
    assert_current_path root_path
  end
end
