class Api::LineusersController < ApplicationController

  def index
    # bot = current_user.bots.includes(:lineusers => :messages).get(params[:bot_id])
    bot = current_user.bots.get(params[:bot_id])
    @lineusers = bot.lineusers.get_open_users
    if params[:status_id].present? && params[:status_id].to_i != 0
      @lineusers = @lineusers.filter_status(params[:status_id])
    end
    if params[:name]
      @lineusers = @lineusers.where("name LIKE ?", "%#{params[:name]}%")
    end
    @lineusers = @lineusers.includes(:lastmessage).order("messages.created_at desc").limit(1000)
    @status_array = bot.get_status_array
  end

  def show
    bot = current_user.bots.get(params[:bot_id])
    @lineuser = bot.lineusers.includes(:messages, :converted_lineuser, :status, :response_data).includes(response_data: :quick_reply).get(params[:id])
  end

  def switch_close
    bot = current_user.bots.get(params[:bot_id])
    lineuser = bot.lineusers.get(params[:id])
    lineuser.switch_close
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
    end
end