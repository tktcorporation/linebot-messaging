class Bot::RemindController < ApplicationController
  before_action :check_auth
  def create
    if Manager.create_remind(remind_params, params[:bot_id], params[:remind_user][:lineusers])
      flash[:notice] = "リマインドを作成しました"
    else
      flash[:notice] = "リマインドの作成に失敗しました"
    end
    redirect_to bot_url(params[:bot_id])
  end
  def edit
    @lineusers_list = Lineuser.get_plural_with_remind_id(params[:id])
    @remind = Remind.get(params[:id])
    @checked_lineuser_array = @remind.remind_users.map{|remind_user| remind_user.lineuser_id}
  end
  def update
    Manager.update_remind(params[:id], remind_params, params[:remind_user][:lineusers])
    #ajaxでは通常のflashmessageは機能しない
    flash[:notice] = "リマインドの内容を更新しました"
    #redirect_to "/bot/remind/#{params[:remind_id]}/edit"
  end
  def destroy
    bot_id = Remind.get(params[:id]).bot.id
    Remind.delete_remind(params[:id])
    redirect_to bot_url(bot_id)
  end
  private
    def remind_params
      params.require(:remind).permit(:name, :text, :ignition_time, :enable)
    end
    def check_auth
      return if !params[:id]
      if Remind.get(params[:id]).bot.user_id != @current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end
end
