class Bot::FormsController < ApplicationController
  before_action :check_auth, :set_bot
  layout 'bot_layout'

  def index
    @bot = current_user.bots.get(params[:bot_id])
    @forms = @bot.forms.includes(:converted_lineusers, :session_lineusers).where(is_active: false)
    @active_form = @bot.forms.includes(:converted_lineusers, :session_lineusers).find_by(is_active: true)
    @active_ab_test = @bot.ab_tests.find_by(is_active: true)
    @new_form = Form.new
  end

  def show
    @form = Form.includes(:quick_replies).get(params[:id])
    bot_id = @form.bot.id
    @bot = current_user.bots.includes(:google_api_set).get(bot_id)
    @quick_replies = @form.quick_replies.includes(:quick_reply_items)
    @quick_reply = @form.quick_replies.new
    @days = ["日", "月", "火", "水", "木", "金", "土"]
  end

  def edit_flow
    @form = Form.includes(:quick_replies).get(params[:id])
    bot_id = @form.bot.id
    @bot = Bot.includes(:google_api_set).get(bot_id)
    @quick_replies = @form.quick_replies.includes(:quick_reply_items)
    @quick_replies_select_array = QuickReply.select_array(@quick_replies)
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
    redirect_to bot_form_url
  end

  def update
    form = Form.get(params[:id])
    form.update_attributes!(form_params)
  end

  private
    def check_auth
      return if !params[:id]
      if Form.get(params[:id]).bot.user_id != @current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end
    def form_params
      params.require(:form).permit(:name, :describe_text, :first_reply_id)
    end
    def set_bot
      @bot = current_user.bots.get(params[:bot_id])
    end
end
