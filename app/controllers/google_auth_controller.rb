APPLICATION_NAME = "calendar"

class GoogleAuthController < ApplicationController
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'
  require 'time'

  def redirect
    # bot = Bot.get(params[:bot_id])
    client = Signet::OAuth2::Client.new(GoogleCalendar.client_options)
    redirect_to client.authorization_uri.to_s
  end

  def callback
    # bot = Bot.get_by_google_auth_hash(params[:hash])
    # bot = Bot.get_with_callback_hash(params[:hash])
    # bot = current_user.bots
    # GoogleCalendar.callback_process(bot, params[:code])
    # redirect_to bot_url(id: bot.id)
    @bots = current_user.bots
    @code = params[:code]
  end

  def set_token
    bot = current_user.bots.get(set_token_params[:bot_id])
    if GoogleCalendar.callback_process(bot, set_token_params[:code])
      redirect_to bot_url(id: bot.id)
    else
      redirect_to bot_url(id: bot.id), alert: "calendar設定に失敗しました"
    end
  end

  def test_create
    bot = Bot.get(params[:bot_id])
    GoogleCalendar.test_create_event(bot, Time.now, 1)
    redirect_back(fallback_location: root_path)
  end


  private
  def set_token_params
    params.permit(:bot_id, :code)
  end

end