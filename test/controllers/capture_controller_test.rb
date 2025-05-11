require "test_helper"

class CaptureControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get capture_index_url
    assert_response :success
  end
end
