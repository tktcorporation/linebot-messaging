class Bot::ReplyActionsController < ApplicationController
  #before_action :check_auth
  before_action :set_bot
  layout 'bot_layout'

  def index
    @reply_actions = @bot.reply_actions.includes(:quick_reply).where(bot_id: @bot.id)
    @quick_reply_list = @bot.quick_replies.where(is_normal_message: false).pluck(:name, :id)
  end

  def create
    reply_action = @bot.reply_actions.new(reply_action_params)
    if reply_action.save
      flash[:notice] = "自動応答を作成しました"
    else
      flash[:notice] = "自動応答の作成に失敗しました"
    end
    redirect_to  bot_reply_actions_url(@bot)
  end

  def update
  end

  def destroy
    reply_action = @bot.reply_actions.get(params[:id])
    reply_action.destroy!
    redirect_to  bot_reply_actions_url(@bot)
  end

  private
    def reply_action_params
      params.require(:bot_reply_action).permit(:quick_reply_id, :name, :text, :is_active)
    end
    def set_bot
      @bot = current_user.bots.get(params[:bot_id])
    end
end