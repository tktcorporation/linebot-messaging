require 'test_helper'

class CustomMessageControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get custom_message_index_url
    assert_response :success
  end

end
