APPLICATION_NAME = "calendar"

class GoogleAuthController < ApplicationController
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'
  require 'time'

  def redirect
    bot = Bot.get(1)
    client = Signet::OAuth2::Client.new(client_options(bot))
    redirect_to client.authorization_uri.to_s
  end

  def callback
    #bot = Bot.get_by_google_auth_hash(params[:hash])
    bot = Bot.get(1)
    GoogleCalendar.callback_process(bot, params[:code])
    redirect_to bot_url(id: 1)
  end

  def create_event
    GoogleCalendar.create_event(QuickReply.find(37), Time.now, 1, Lineuser.find(13))
    redirect_to "/"
  end

  def get_events
    day = Time.now
    Manager.extract_free_time(Manager.available_array_week(day), day)
    redirect_to "/"
  end

  private
  def client_options(bot)
    return client_option = {
      client_id: bot.google_api_set.client_id,
      client_secret: bot.google_api_set.client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://www.googleapis.com/oauth2/v4/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: 'https://catalyst-app-production.herokuapp.com/google_auth/callback',
      additional_parameters: {prompt:'consent'},
    }
  end

end