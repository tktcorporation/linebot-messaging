class BotController < ApplicationController
  before_action :check_auth
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
    @bot = Bot.get(params[:id])
    @domain = ENV.fetch('DOMAIN_NAME')
    if @bot.notify_token
      @access_token = @bot.notify_token.access_token
      @notify_checked = @bot.notify
    end
    render layout: 'bot_layout'
  end
  def update
    bot = Bot.get(params[:id])
    if bot.update(bot_params)
      NotifyToken.update_or_create(params[:notify_token][:access_token], params[:id])
    else
      flash[:notice] = "更新に失敗しました"
    end
  end

  def show
    @bot = Bot.includes(:lineusers, :reminds, :logs).includes(:lineusers => :messages).get(params[:id])
    render layout: 'bot_layout'
  end

  private
    def bot_params
      params.require(:bot).permit(:name, :channel_token, :channel_secret, :description, :notify)
    end
    def check_auth
      Bot.get(params[:id]).user_id != @current_user.id ? raise("you don't have auth of the id") : true if params[:id]
    end
end