class ChatController < ApplicationController
  skip_before_action :require_sign_in!, only: [:callback, :private_callback, :test_push, :top]

  def index
    @bot = Bot.includes(:lineusers => :messages).get(params[:bot_id])
    render :show
  end

  def show
    #トーク履歴が多いと重くなりそう
    @bot = Bot.includes(:lineusers).includes(:lineusers => :lastmessage).get(params[:bot_id])
    #:replied に返信済みユーザーが, :not_repliedに未返信ユーザーが配列で入る
    @lineusers = Manager.sort_by_is_replied(@bot.lineusers)
    @lineuser = Lineuser.includes(:messages, :response_data).get(params[:lineuser_id])
    @quick_reply_list = @bot.quick_replies.where(is_normal_message: false)
    #Manager.update_lineuser_profile(@bot, @lineuser.uid)
  end

  def create
    msg = params[:message]
    Manager.push(Lineuser.get(params[:lineuser_id]), msg)
    redirect_to bot_chat_path(params[:bot_id], params[:lineuser_id])
  end

  def update_name
    username = params[:name]
    Manager.push_name(params[:lineuser_id], username)
    redirect_to bot_chat_path(params[:bot_id], params[:lineuser_id])
  end

  private
    def check_auth
      if params[:lineuser_id]
        Lineuser.get(params[:lineuser_id]).bot.user_id != current_user.id ? raise("you don't have auth of the id") : true
      end
    end

end
