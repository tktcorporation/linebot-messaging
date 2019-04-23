class Api::LineusersController < ApplicationController

  def index
    # bot = current_user.bots.includes(:lineusers => :messages).get(params[:bot_id])
    bot = current_user.bots.get(params[:bot_id])
    if params[:status_id].present? && params[:status_id].to_i != 0
      @lineusers = bot.lineusers.includes(:lastmessage).filter_status(params[:status_id])
    else
      @lineusers = bot.lineusers.includes(:lastmessage)
    end
    if params[:name]
      @lineusers = @lineusers.where("name LIKE ?", "%#{params[:name]}%")
    end
    @lineusers = @lineusers.followed.includes(:lastmessage).order("messages.created_at desc").limit(1000)
    @status_array = bot.get_status_array
  end

  def show
    bot = current_user.bots.get(params[:bot_id])
    @lineuser = bot.lineusers.includes(:messages, :converted_lineuser, :status, :response_data).includes(response_data: :quick_reply).get(params[:id])
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
    end
end