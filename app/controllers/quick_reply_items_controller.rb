class QuickReplyItemsController < ApplicationController
  before_action :check_auth
  def create
    quick_reply = QuickReply.get(params[:quick_reply_id])
    quick_reply.switch_quick_reply
    quick_reply_item = quick_reply.quick_reply_items.new(quick_reply_item_params)
    quick_reply_item.save!
    redirect_to form_url(quick_reply.form_id)
  end

  def destroy
    quick_reply_item = QuickReplyItem.get(params[:id])
    quick_reply_item.destroy
    redirect_to form_url(quick_reply_item.quick_reply.form_id)
  end

  private
    def check_auth
      return if !params[:id]
      if QuickReplyItem.get(params[:id]).quick_reply.form.bot.user_id != @current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end
    def quick_reply_item_params
      params.require(:quick_reply_item).permit(:text)
    end
end
