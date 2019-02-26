class Bot::LineusersController < ApplicationController
  before_action :check_auth
  layout 'bot_layout'

  def index
    @bot = current_user.bots.includes(:lineusers, :reminds).includes(:lineusers => :messages).get(params[:bot_id])
    @newremind = @bot.reminds.new
  end

  def show
    form = Form.includes(:quick_replies).get(params[:id])
    @bot = form.bot
    @quick_replies = form.quick_replies.includes(:quick_reply_items)
    @quick_reply = form.quick_replies.new
  end

  private
    def check_auth
      return if !params[:id]
      if Lineuser.get(params[:id]).bot.user_id != @current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end
    def form_params
      params.require(:lineuser).permit(:name)
    end
end
