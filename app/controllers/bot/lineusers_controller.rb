class Bot::LineusersController < ApplicationController
  layout 'bot_layout'
  def index
    @bot = current_user.bots.get(params[:bot_id])
    # @quick_reply_list = @bot.quick_replies.where(is_normal_message: false)
    @lineusers = @bot.lineusers.includes(:quick_reply, :converted_lineuser, :lineuser_status, :lastmessage).get_open_users.order("messages.created_at asc").last(50)
    @status_array = @bot.get_status_array
  end
end
