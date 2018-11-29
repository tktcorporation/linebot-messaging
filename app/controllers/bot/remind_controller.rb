class RemindController < ApplicationController
  def create
    p bot_url(params[:bot_id])
    if Manager.create_remind(remind_params, params[:bot_id], params[:remind_user][:lineusers])
      flash[:notice] = "リマインドを作成しました"
    else
      flash[:notice] = "リマインドの作成に失敗しました"
    end
    p bot_url(params[:bot_id])
    redirect_to bot_url(params[:bot_id])
  end
  def edit
    @lineusers_list = Lineuser.get_plural_with_remind_id(params[:remind_id])
    @remind = Remind.get(params[:remind_id])
    @checked_lineuser_array = @remind.remind_users.map{|remind_user| remind_user.lineuser_id}
  end
  def update
    Manager.update_remind(params[:remind_id], remind_params, params[:remind_user][:lineusers])
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
      Remind.get(params[:id]).bot.user_id != current_user.id ? raise("you don't have auth of the id") : true
    end
end