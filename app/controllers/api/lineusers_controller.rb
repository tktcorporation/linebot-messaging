class Api::LineusersController < ApplicationController

  def index
    # bot = current_user.bots.includes(:lineusers => :messages).get(params[:bot_id])
    bot = current_user.bots.get(params[:bot_id])
    if params[:status_id].present? && params[:status_id].to_i != 0
      @lineusers = bot.lineusers.includes(:lastmessage).filter_status(params[:status_id])
    else
      @lineusers = bot.lineusers.includes(:lastmessage)
    end
    @lineusers = @lineusers.followed.includes(:lastmessage).order("messages.created_at desc")
  end

  def show
    bot = current_user.bots.get(params[:bot_id])
    if params[:status_id].present? && params[:status_id].to_i != 0
      @lineusers = bot.lineusers.includes(:lastmessage).filter_status(params[:status_id])
    else
      @lineusers = bot.lineusers.includes(:lastmessage)
    end
    @lineusers = @lineusers.followed.includes(:lastmessage).order("messages.created_at desc")
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
    end
end