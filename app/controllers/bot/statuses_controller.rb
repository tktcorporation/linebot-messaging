class Bot::StatusesController < ApplicationController
  before_action :check_auth
  layout 'bot_layout'

  def index
    @bot = Bot.get(params[:bot_id])
    @statuses = Bot::Status.where(bot_id: @bot.id, deleted: false)
  end

  def create
    bot = Bot.get(params[:bot_id])
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
    if status.destroy
      flash[:notice] = "削除しました"
    else
      flash[:notice] = "削除に失敗しました"
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