class Bot::AbTestsController < ApplicationController
  before_action :set_bot
  layout 'bot_layout'

  def index
    @forms = @bot.forms
    @ab_test = @bot.ab_tests.new
  end

  def show

  end

  def create
    ActiveRecord::Base.transaction do
      ab_test = @bot.ab_tests.new(ab_test_params)
      ab_test.save!
      Bot::AbTest.associate_forms(ab_test, ab_test_forms_params[:ab_test_forms_attributes][:form_ids])
    end
    redirect_to bot_ab_tests_path(@bot.id)
  rescue => e
    Rails.logger.fatal e.message
    redirect_to bot_ab_tests_path(@bot.id), alert: "作成に失敗しました"

  end

  private
  def set_bot
    @bot = current_user.bots.get(params[:bot_id])
  end
  def ab_test_params
    params.require(:bot_ab_test).permit(:name, :is_active)
  end
  def ab_test_forms_params
    params.require(:bot_ab_test).permit(ab_test_forms_attributes: {form_ids: []} )
  end
end
