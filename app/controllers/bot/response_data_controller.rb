class Bot::ResponseDataController < ApplicationController
  layout 'bot_layout'
  def index
    @bot = Bot.get(params[:bot_id])
    @quick_reply_list = @bot.quick_replies.where(is_normal_message: false)
    @lineusers = @bot.lineusers.includes(:response_data, :converted_lineuser, :quick_reply, :lineuser_status)
    @status_array = @bot.get_status_array
  end
end
