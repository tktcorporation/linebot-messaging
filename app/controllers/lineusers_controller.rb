class LineusersController < ApplicationController
  before_action :check_auth
  layout 'bot_layout'

  def index
    @bot = Bot.includes(:lineusers, :reminds).includes(:lineusers => :messages).get(params[:bot_id])
    @newremind = Remind.new
  end

  def show
    form = Form.includes(:quick_replies).get(params[:id])
    @quick_replies = form.quick_replies.includes(:quick_reply_items)
    @quick_reply = form.quick_replies.new
  end

  private
    def check_auth
      Lineuser.get(params[:id]).bot.user_id != @current_user.id ? raise("you don't have auth of the id") : true if params[:id]
    end
    def form_params
      params.require(:lineuser).permit(:name)
    end
end
