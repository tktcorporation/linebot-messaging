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
    Manager.update_lineuser_profile(@bot, @lineuser.uid, false)
    @value = {message: params[:redirect_message], name: params[:redirect_name]} #if params[:redirect_message] && params[:redirect_name]
  end

  def redirect
    @bot = Bot.includes(:lineusers).includes(:lineusers => :lastmessage).get(params[:bot_id])
    #:replied に返信済みユーザーが, :not_repliedに未返信ユーザーが配列で入る
    @lineusers = Manager.sort_by_is_replied(@bot.lineusers)
    @lineuser = Lineuser.includes(:messages, :response_data).get(params[:lineuser_id])
    @quick_reply_list = @bot.quick_replies.where(is_normal_message: false)
    @value = {message: params[:redirect_message], name: params[:redirect_name]}
    render :show
  end

  def create
    msg = params[:message]
    Manager.push(Lineuser.get(params[:lineuser_id]), msg)
    redirect_to bot_chat_path(params[:bot_id], params[:lineuser_id])
  end

  def update_name
    @bot = Bot.get(params[:bot_id])
    @lineuser = Lineuser.get(params[:lineuser_id])
    Manager.save_or_refresh_name(@bot, @lineuser, params[:name])
    redirect_to bot_chat_path(params[:bot_id], params[:lineuser_id])
  end

  private
    def check_auth
      return if !params[:id]
      if Lineuser.get(params[:lineuser_id]).bot.user_id != current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end

end
