class Bot::LineusersController < ApplicationController
  layout 'bot_layout'
  def index
    @bot = current_user.bots.get(params[:bot_id])
    # @quick_reply_list = @bot.quick_replies.where(is_normal_message: false)
    @lineusers = @bot.lineusers.get_open_users
    @lineusers = @lineusers.includes(:lastmessage, :quick_reply, :converted_lineuser, :lineuser_status).order("messages.created_at desc").limit(30)
    @status_array = @bot.get_status_array
  end
end
