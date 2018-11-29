class ChatController < ApplicationController
  skip_before_action :require_sign_in!, only: [:callback, :private_callback, :test_push, :top]
  protect_from_forgery except: :callback
  protect_from_forgery except: :private_callback

  def room
    if params[:lineuser_id]
      @lineuser = Lineuser.get(params[:lineuser_id])
      @messages = Message.get_plural_with_lineuser_id(params[:lineuser_id])
    end
    @bot = Bot.get(params[:bot_id])
    @lineusers_list = Lineuser.get_plural_with_bot_id(params[:bot_id])
    @last_messages = Manager.get_last_messages(@lineusers_list)
  end

  def roompush
    msg = params[:message]
    Manager.push(params[:lineuser_id], msg)
    redirect_to "/chat/#{params[:bot_id]}/#{params[:lineuser_id]}"
  end

  def namepush
    username = params[:name]
    Manager.push_name(params[:lineuser_id], username)
    redirect_to "/chat/#{params[:bot_id]}/#{params[:lineuser_id]}"
  end

end
