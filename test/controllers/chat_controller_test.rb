require 'test_helper'

class ChatControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get chat_top_url
    assert_response :success
  end

end
