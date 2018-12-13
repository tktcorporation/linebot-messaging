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
    ActiveRecord::Base.transaction do
      QuickReply.optional_create(params[:form_id], quick_reply_params)
    end
    redirect_to "/forms/#{params[:form_id]}"
  end

  def destroy
    quick_reply = QuickReply.get(params[:id])
    ActiveRecord::Base.transaction do
      quick_reply.relational_delete
    end
    redirect_to "/forms/#{quick_reply.form.id}"
  end

  def update
    quick_reply = QuickReply.get(params[:id])
    ActiveRecord::Base.transaction do
      quick_reply.update_attributes!(quick_reply_flow_params)
      QuickReplyItem.update_nexts(items_flow_params)
    end
    #redirect_to "/forms/#{quick_reply.form.id}/edit_flow"
  end

  private
    def check_auth
      QuickReply.get(params[:id]).form.bot.user_id != @current_user.id ? raise("you don't have auth of the id") : true if params[:id]
    end
    def quick_reply_params
      params.require(:quick_reply).permit(:name, :text, :reply_type, :summary, :duration_days)
    end
    def quick_reply_flow_params
      params.require(:quick_reply).permit(:next_reply_id)
    end
    def items_flow_params
      params.require(:quick_reply).permit(quick_reply_items: :next_reply_id)[:quick_reply_items]
    end
end
