require 'test_helper'

class QuickRepliesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get quick_replies_show_url
    assert_response :success
  end

end
