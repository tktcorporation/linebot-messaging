class UsersController < ApplicationController
  skip_before_action :require_sign_in!, only: [:create, :new]
  def new
    @current_user ? redirect_to(user_url) : @user = User.new
  end
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        puts("created new user")
        flash[:notice] = "新規ユーザーを作成しました"
        format.js { render ajax_redirect_to(root_url) }
      else
        format.js { render partial: 'shared/error_remote', locals: {model: @user} }
      end
    end
  end
  def show
    @bots = Bot.get_plural_with_user_id(@current_user.id)
    @bot = Bot.new
  end
  private
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end