require 'test_helper'

class ResponseDataControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get response_data_show_url
    assert_response :success
  end

end
