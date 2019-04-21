class Bot::CustomMessageController < ApplicationController
  layout 'bot_layout'
  def index
    @bot = current_user.bots.includes(:reminds, :lineusers).get(params[:bot_id])
    @lineusers = @bot.lineusers.includes(:lastmessage).order("messages.created_at desc").limit(100)
    @search = LineuserSearch.new
    @newremind = Remind.new
    #render json: @users.select("id").map { |e| e.id  }.to_json unless params[:q].blank?
  end

  def search
    @bot = Bot.includes(:reminds, :lineusers).get(params[:bot_id])
    @search = LineuserSearch.new(search_params)
    @newremind = Remind.new
    if search_params.permitted?
      @lineusers = Lineuser.custom_search(@bot.lineusers, search_params)
    end
    render :index
  end

  private
    def search_params
      params.require(:lineuser_search).permit(:name, :convert_time_from, :convert_time_to, :session_time_from, :session_time_to, :messages_created_at_from, :messages_created_at_to, :limit)
    end
end
