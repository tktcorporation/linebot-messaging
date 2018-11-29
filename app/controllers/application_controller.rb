class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :current_user
  before_action :require_sign_in!, except: [:errors]
  before_action :check_authority
  helper_method :signed_in?

  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        sign_in(user)
        @current_user = user
      end
    end
  end

    # 渡されたユーザーでログインする
  def sign_in(user)
    session[:user_id] = user.id
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def signed_in?
    !current_user.nil?
  end

  def ajax_redirect_to(redirect_uri)
    { js: "window.location.replace('#{redirect_uri}');" }
  end

  def check_authority
    if bot_id = params[:bot_id]
      if Bot.get(bot_id).user.id != @current_user.id
        raise("you don't have auth of the id")
      end
    end
    if lineuser_id = params[:lineuser_id]
      if Lineuser.get(lineuser_id).bot.user.id != @current_user.id
        raise("you don't have auth of the id")
      end
    end
    if remind_id = params[:remind_id]
      if Remind.get(remind_id).bot.user.id != @current_user.id
        raise("you don't have auth of the id")
      end
    end
    if quick_reply_id = params[:quick_reply_id]
      if QuickReply.get(quick_reply_id).form.bot.user.id != @current_user.id
        raise("you don't have auth of the id")
      end
    end
    if form_id = params[:form_id]
      if Form.get(form_id).bot.user.id != @current_user.id
        raise("you don't have auth of the id")
      end
    end
  end

  #rescue_from Exception, :with => :error_500
  #rescue_from ActiveRecord::RecordNotFound, with: :render_404
  #rescue_from SelfAutholicationError, with: :render_404
  #rescue_from ActionController::RoutingError, with: :render_404

  def render_404(e = nil)
    if e
      logger.error e
      logger.error e.backtrace.join("\n")
    end

    render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
  end

  def error_500(e = nil)
    if e
      logger.error e
      logger.error e.backtrace.join("\n")
    end

    render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
  end

  private

    def require_sign_in!
      flash[:notice] = "ログインが必要です" unless signed_in?
      redirect_to :root unless signed_in?
    end
end
