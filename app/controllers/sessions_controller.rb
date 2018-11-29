class SessionsController < ApplicationController
  skip_before_action :require_sign_in!, except: [:destroy]

  def create
    user = User.find_by(email: params[:user][:email].downcase)
    respond_to do |format|
      if user && user.authenticate(params[:user][:password])
        sign_in(user)
        remember(user)
        format.js { render ajax_redirect_to(root_url), notice: "ログインしました。" }
      else
        format.js { render :login_validates }
      end
    end
  end


  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def destroy
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
    redirect_to root_url, notice: "ログアウトしました"
  end
  private
    def user_params
      params.require(:user).permit(:email, :password)
    end
end