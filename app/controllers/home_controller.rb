class HomeController < ApplicationController
  skip_before_action :require_sign_in!
  def top
    @current_user ? redirect_to(user_url) : @user = User.new
  end
end