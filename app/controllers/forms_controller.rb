class FormsController < ApplicationController
  before_action :check_auth
  layout 'bot_layout'

  def index
    bot = Bot.get(params[:bot_id])
    @forms = bot.forms.includes(:converted_lineusers, :session_lineusers).where(is_active: false)
    @active_form = bot.forms.includes(:converted_lineusers, :session_lineusers).find_by(is_active: true)
    @new_form = Form.new
  end

  def show
    @form = Form.includes(:quick_replies).get(params[:id])
    @quick_replies = @form.quick_replies.includes(:quick_reply_items)
    @quick_reply = @form.quick_replies.new
  end

  def create
    bot = Bot.get(params[:bot_id])
    form = bot.forms.new(form_params)
    form.save!
    redirect_to bot_forms_url
  end

  def switch_active
    form = Form.get(params[:id])
    form.switch_active_do(form)
    redirect_to form_url
  end

  private
    def check_auth
      Form.get(params[:id]).bot.user_id != @current_user.id ? raise("you don't have auth of the id") : true if params[:id]
    end
    def form_params
      params.require(:form).permit(:name, :describe_text)
    end
end
