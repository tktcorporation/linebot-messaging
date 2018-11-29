class QuickRepliesController < ApplicationController
  before_action :check_auth
  def index
    bot = Bot.get(params[:bot_id])
    @quick_replies = bot.quick_replies.includes(:quick_reply_items)
    @quick_reply = QuickReply.new
  end

  def show
    @quick_reply = QuickReply.includes(:quick_reply_items).get(params[:id])
  end

  def new
    @quick_reply = QuickReply.new
  end

  def create
    QuickReply.create(params[:form_id], quick_reply_params)
    redirect_to "/forms/#{params[:form_id]}"
  end

  def delete
    QuickReply.delete(params[:id])
    redirect_to "/forms/#{params[:form_id]}"
  end

  private
    def check_auth
      QuickReply.get(params[:id]).form.bot.user_id != @current_user.id ? raise("you don't have auth of the id") : true if params[:id]
    end
    def quick_reply_params
      params.require(:quick_reply).permit(:name, :descrive_text, :text)
    end
end
