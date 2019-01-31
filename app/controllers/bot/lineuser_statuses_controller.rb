class Bot::LineuserStatusesController < ApplicationController
  before_action :check_auth

  def create
    lineuser = Lineuser.get(params[:lineuser_id])
    Bot::LineuserStatus.create_or_update(lineuser_status_params, lineuser)
  end

  def update
    lineuser = Lineuser.get(params[:lineuser_id])
    lineuser.lineuser_status.update_attributes!(lineuser_status_params)
  end

  def destroy

  end

  private
  def lineuser_status_params
    params.require(:bot_lineuser_status).permit(:status_id)
  end
  def check_auth
    return if !lineuser_status_params[:status_id].present?
    if Lineuser.get(params[:lineuser_id]).bot.user_id != current_user.id
      render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
    end
  end
end