class Bot::StatusesController < ApplicationController
  before_action :check_auth
  layout 'bot_layout'

  def index
    @bot = current_user.bots.get(params[:bot_id])
    @statuses = @bot.statuses.where(bot_id: @bot.id, deleted: false)
  end

  def create
    bot = current_user.bots.get(params[:bot_id])
    status = bot.statuses.new(status_params)
    if status.save
      flash[:notice] = "ステータスを追加しました"
    else
      flash[:notice] = "ステータスの追加に失敗しました"
    end
    redirect_back(fallback_location: root_path)
  end
  def update

  end
  def destroy
    status = Bot::Status.get(params[:id])
    redirect_back(fallback_location: root_path, alert: "削除に失敗しました") if status.bot.user_id != current_user.id
    if status.destroy
      flash[:notice] = "削除しました"
    else
      flash[:notice] = "削除に失敗しました"
    end
    redirect_back(fallback_location: root_path)
  end

  def switch_active
    status = Bot::Status.get(params[:id])
    redirect_back(fallback_location: root_path, alert: "更新に失敗しました") if status.bot.user_id != current_user.id
    if status.switch_active
      flash[:notice] = "更新しました"
    else
      flash[:notice] = "更新に失敗しました"
    end
    redirect_back(fallback_location: root_path)
  end

  private
    def status_params
      params.require(:bot_status).permit(:name)
    end
    def check_auth
      return if !params[:id]
      if Bot::Status.get(params[:id]).bot.user_id != @current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end
end