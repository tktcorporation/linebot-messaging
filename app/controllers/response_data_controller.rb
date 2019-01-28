class ResponseDataController < ApplicationController
  layout 'bot_layout'
  def index
    @bot = Bot.get(params[:bot_id])
    @quick_reply_list = @bot.quick_replies.where(is_normal_message: false)
    @lineusers = @bot.lineusers.includes(:response_data)
  end
end
