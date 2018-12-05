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
    GoogleCalendar.create_event
  end

  def get_events
    calendar_events = GoogleCalendar.get_events
    available_array = []
    47.times do |i|
      if i == 0
        available_array.push(1)
      else
        available_array.push(0)
      end
    end
    day = Time.parse("2018/12/07 19:23:55")
    calendar_events.each do |event|
      available_array = Manager.available_time(event, day, available_array)
    end
    p "======available_array========="
    p available_array
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