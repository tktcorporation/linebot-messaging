class Bot::Forms::CheckNotificationsController < ApplicationController
  before_action :set_bot_form
  layout 'bot_layout'

  def index
    @check_notification = @bot.check_notifications.includes(:quick_replies).first
    @new_check_notification = @bot.check_notifications.new
    @quick_replies = @form.quick_replies
  end

  def create
    ActiveRecord::Base.transaction do
      check_notification = @bot.check_notifications.new(check_notification_params)
      check_notification.save!
      Bot::CheckNotification.associate_quick_replies(check_notification, check_notification_quick_replies_params[:check_notification_quick_replies_attributes][:quick_reply_ids], @form)
    end
    redirect_to bot_form_check_notifications_path(@bot.id, @form)
  rescue => e
    Rails.logger.fatal e.message
    redirect_to bot_form_check_notifications_path(@bot.id, @form), alert: "作成に失敗しました"
  end

  def destroy
    check_notification = @bot.check_notifications.get(params[:id])
    check_notification.destroy!
    redirect_to bot_form_check_notifications_path(@bot.id, @form)
  end

  # def switch_active
  #   check_notification = @bot.check_notifications.get(params[:id])
  #   ActiveRecord::Base.transaction do
  #     check_notification.switch_active
  #   end
  #   redirect_to bot_check_notifications_path(@bot.id)
  # rescue => e
  #   Rails.logger.fatal e.message
  #   redirect_to bot_check_notifications_path(@bot.id), alert: "エラーが発生しました"
  # end

  private
  def set_bot_form
    @bot = current_user.bots.get(params[:bot_id])
    @form = @bot.forms.get(params[:form_id])
  end
  def check_notification_params
    params.require(:bot_check_notification).permit(:name)
  end
  def check_notification_quick_replies_params
    params.require(:bot_check_notification).permit(check_notification_quick_replies_attributes: {quick_reply_ids: []} )
  end
end
