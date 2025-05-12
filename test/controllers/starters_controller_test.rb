require "test_helper"

class StartersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get starters_new_url
    assert_response :success
  end

  test "should get create" do
    get starters_create_url
    assert_response :success
  end
end
