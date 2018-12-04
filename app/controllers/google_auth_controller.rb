CLIENT_OPTIONS = {
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://www.googleapis.com/oauth2/v4/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: 'https://catalyst-app-production.herokuapp.com/google_auth/callback',
      additional_parameters: {prompt:'consent'},
    }

APPLICATION_NAME = "calendar"

class GoogleAuthController < ApplicationController
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'

  def redirect
    client = Signet::OAuth2::Client.new(CLIENT_OPTIONS)
    redirect_to client.authorization_uri.to_s
  end

  def callback
    #bot = Bot.get_by_google_auth_hash(params[:hash])
    bot = Bot.find(1)
    GoogleCalendar.callback_process(bot, code)
    redirect_to bot_url(id: 1)
  end

  def create_event
    GoogleCalendar.create_event
  end

  def get_events
    GoogleCalendar.get_events
    redirect_to "/"
  end






end