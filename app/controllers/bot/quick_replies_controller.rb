class Bot::QuickRepliesController < ApplicationController
  before_action :check_auth, :set_bot
  def index
    @quick_replies = @bot.quick_replies.includes(:quick_reply_items)
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
      QuickReply.optional_create(params[:form_id], quick_reply_params, quick_reply_schedule_params)
    end
    redirect_to bot_form_url(@bot.id, params[:form_id])
  rescue => e
    flash[:notice] = e.message
    redirect_to bot_form_url(@bot.id, params[:form_id])
  end

  def destroy
    quick_reply = QuickReply.get(params[:id])
    ActiveRecord::Base.transaction do
      quick_reply.relational_delete
    end
    redirect_to bot_form_url(@bot.id, quick_reply.form.id)
  end

  def update
    quick_reply = QuickReply.get(params[:id])
    ActiveRecord::Base.transaction do
      quick_reply.update_attributes!(quick_reply_flow_params)
      QuickReplyItem.update_nexts(items_flow_params)
    end
  rescue => e
    flash[:notice] = e.message
    redirect_to edit_flow_bot_form_url(@bot.id, quick_reply.form.id)
  end

  def text_update
    quick_reply = QuickReply.get(params[:id])
    quick_reply.update_attributes!(quick_reply_update_params)
    redirect_to bot_form_url(@bot.id, quick_reply.form.id)
  end

  private
    def check_auth
      return if !params[:id]
      if QuickReply.get(params[:id]).form.bot.user_id != @current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end
    def quick_reply_params
      params.require(:quick_reply).permit(:name, :text, :reply_type)
    end
    def quick_reply_update_params
      params.require(:quick_reply).permit(:name, :text)
    end
    def quick_reply_schedule_params
      params.require(:quick_reply).permit(:summary, :duration_days, :duration_num, :start_num, :term_num, :permission_count, available_day: %i(0 1 2 3 4 5 6))
    end
    def quick_reply_flow_params
      params.require(:quick_reply).permit(:next_reply_id)
    end
    def items_flow_params
      params.require(:quick_reply).permit(quick_reply_items: :next_reply_id)[:quick_reply_items]
    end
    def set_bot
      if params[:bot_id].present?
        @bot = current_user.bots.get(params[:bot_id])
      else
        @bot = current_user.bots.joins({:forms => :quick_replies}).find_by(quick_replies: {id: params[:id]})
      end
    end
end
