require "test_helper"

class HealingCenterControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get healing_center_index_url
    assert_response :success
  end
end
