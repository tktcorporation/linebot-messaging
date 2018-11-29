require 'test_helper'

class LineusersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get lineusers_index_url
    assert_response :success
  end

end
