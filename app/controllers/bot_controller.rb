class BotController < ApplicationController
  before_action :check_auth
  layout 'bot_layout'

  def create
    if Manager.create_new_bot(bot_params, @current_user.id)
      flash[:notice] = "新しいLinebotを登録しました"
      redirect_to user_url
    else
      flash[:notice] = "登録に失敗しました"
      render :show
    end
  end
  def edit
    @bot = @current_user.bots.get(params[:id])
    @domain = ENV.fetch('DOMAIN_NAME')
    if @bot.notify_token
      @access_token = @bot.notify_token.access_token
      @notify_checked = @bot.notify
    end
    render layout: 'bot_layout'
  end
  def update
    bot = @current_user.bots.get(params[:id])
    ActiveRecord::Base.transaction do
      if bot.update(bot_params)
        NotifyToken.update_or_create(params[:id], params[:bot][:notify_token][:access_token])
        GoogleApiSet.update_or_create(params[:id], params[:bot][:google_api_set][:client_id], params[:bot][:google_api_set][:client_secret])
        Bot::SlackApiSet.update_or_create(bot, params[:bot][:slack_api_set][:webhook_url])
        redirect_to edit_bot_path(bot), notice: "更新しました"
      else
        redirect_to edit_bot_path(bot), alert: "更新に失敗しました"
      end
    end
  rescue => e
    Rails.logger.fatal e.message
    redirect_to edit_bot_path(bot), alert: "更新に失敗しました"
  end

  def set_images
    bot = @current_user.bots.get(params[:id])
    if bot.images.attach(bot_images_params[:images])
      flash[:notice] = "新しい画像を登録しました"
    else
      flash[:alert] = "画像の登録に失敗しました"
    end
    redirect_back(fallback_location: root_path)
  end

  def show
    @bot = @current_user.bots.includes(:lineusers, :reminds, :logs).includes(:lineusers => :messages).get(params[:id])
    render layout: 'bot_layout'
  end

  private
    def bot_params
      params.require(:bot).permit(:name, :channel_token, :channel_secret, :description, :notify)
    end
    def bot_images_params
      params.require(:bot).permit(images: [])
    end
    def check_auth
      return if !params[:id]
      if Bot.get(params[:id]).user_id != @current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end
end