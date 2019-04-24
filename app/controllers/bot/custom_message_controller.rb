class Bot::CustomMessageController < ApplicationController
  layout 'bot_layout'
  def index
    @bot = current_user.bots.includes(:reminds, :lineusers).get(params[:bot_id])
    @lineusers = @bot.lineusers.includes(:lastmessage).order("messages.created_at desc").limit(100)
    @search = LineuserSearch.new
    @status_array = @bot.get_status_array
    #render json: @users.select("id").map { |e| e.id  }.to_json unless params[:q].blank?
  end

  def search
    @bot = Bot.includes(:reminds, :lineusers).get(params[:bot_id])
    @status_array = @bot.get_status_array
    @search = LineuserSearch.new(search_params)
    if search_params.permitted?
      @lineusers = Lineuser.custom_search(@bot.lineusers, search_params)
    end
    @lineusers = @lineusers.includes(:lastmessage).order("messages.created_at desc")
    render :index
  end

  def broadcast
    lineusers = current_user.bots.get(params[:bot_id]).lineusers.where(id: broadcast_params[:lineusers])
    Manager.push_multicast(lineusers, broadcast_params[:text])
    redirect_to bot_custom_message_index_path(params[:bot_id]), notice: "一斉送信を実行しました"
  end

  private
    def search_params
      params.require(:lineuser_search).permit(:name, :convert_time_from, :convert_time_to, :session_time_from, :session_time_to, :messages_created_at_from, :messages_created_at_to, :limit, :status_id)
    end
    def broadcast_params
      params.require(:broadcast).permit(:text, lineusers: [])
    end
end
