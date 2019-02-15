class Bot::ReplyActionsController < ApplicationController
  before_action :check_auth
  before_action :set_bot, only: [:index, :create]
  layout 'bot_layout'

  def index
    @bot = Bot.get(params[:bot_id])
    @reply_actions = Bot::ReplyAction.where(bot_id: @bot.id)
    @quick_reply_list = @bot.quick_replies.where(is_normal_message: false).pluck(:name, :id)
  end

  def create
    reply_action = @bot.reply_actions.new(reply_action_params)
    reply_action.save!
    redirect_to  bot_reply_actions_url(@bot)
  end

  def update
  end

  def destroy
    reply_action = Bot::ReplyAction.get(params[:id])
    reply_action.destroy!
  end

  private
    def reply_action_params
      params.require(:bot_reply_action).permit(:quick_reply_id, :name, :text, :is_active)
    end
    def check_auth
      return if !params[:id].present?
      if Bot::ReplyAction.get(params[:id]).bot.user_id != current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
      # if QuickReply.get(params[:quick_reply_id]).bot.user_id != current_user.id
      #   render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      # end
    end
    def set_bot
      @bot = Bot.get(params[:bot_id])
    end
end