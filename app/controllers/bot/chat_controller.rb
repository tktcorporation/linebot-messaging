class Bot::ChatController < ApplicationController
  before_action :check_auth, :set_bot

  def index
    @bot = current_user.bots.includes(:lineusers => :messages).get(params[:bot_id])
    render :show
  end

  def show
    #トーク履歴が多いと重くなりそう
    @bot = current_user.bots.with_attached_images.includes(:lineusers, :statuses).includes(:lineusers => :lastmessage).get(params[:bot_id])
    #:replied に返信済みユーザーが, :not_repliedに未返信ユーザーが配列で入る
    @lineusers = Manager.sort_by_is_replied(@bot.lineusers)
    @lineuser = @bot.lineusers.includes(:messages, :response_data).get(params[:lineuser_id])
    @quick_reply_list = @bot.quick_replies.where(is_normal_message: false)
    Manager.update_lineuser_profile(@bot, @lineuser.uid, false)
    @value = {message: params[:redirect_message], name: params[:redirect_name]} #if params[:redirect_message] && params[:redirect_name]
    @status_array = @bot.get_status_array
  end

  def redirect
    @bot = current_user.bots.includes(:lineusers).includes(:lineusers => :lastmessage).get(params[:bot_id])
    #:replied に返信済みユーザーが, :not_repliedに未返信ユーザーが配列で入る
    @lineusers = Manager.sort_by_is_replied(@bot.lineusers)
    @lineuser = @bot.lineusers.includes(:messages, :response_data).get(params[:lineuser_id])
    @quick_reply_list = @bot.quick_replies.where(is_normal_message: false)
    @value = {message: params[:redirect_message], name: params[:redirect_name]}
    render :show
  end

  def create
    msg = params[:message]
    Manager.push(@bot.lineusers.get(params[:lineuser_id]), msg)
    redirect_to bot_chat_path(params[:bot_id], params[:lineuser_id])
  end

  def update_name
    @lineuser = @bot.lineusers.get(params[:lineuser_id])
    Manager.save_or_refresh_name(@bot, @lineuser, params[:name])
    redirect_to bot_chat_path(params[:bot_id], params[:lineuser_id])
  end

  def push_flex
    lineuser = @bot.lineusers.get(params[:lineuser_id])
    quick_reply = @bot.quick_replies.get(params[:quick_reply][:id])
    Manager.push_flex(lineuser, quick_reply)
    redirect_to bot_chat_path(@bot.id, lineuser.id)
  end

  def push_image
    image = @bot.images.find_by(image_param)
    lineuser = @bot.lineusers.get(params[:lineuser_id])
    ActiveRecord::Base.transaction do
      Manager.push_image(lineuser, image, url_for(image))
    end
    redirect_to bot_chat_path(@bot.id, lineuser.id)
  rescue => e
    Rails.logger.fatal e.message
    redirect_to bot_chat_path(@bot.id, lineuser.id), alert: "エラーが発生しました"
  end

  private
    def check_auth
      return if !params[:id]
      if Lineuser.get(params[:lineuser_id]).bot.user_id != current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end

    def set_bot
      @bot = current_user.bots.get(params[:bot_id])
    end

    def image_param
      params.require(:image).permit(:id)
    end

end
