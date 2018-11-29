CLIENT_OPTIONS = {
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://www.googleapis.com/oauth2/v4/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: 'https://linebot-messaging.herokuapp.com/google_auth/callback',
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
    client = Signet::OAuth2::Client.new(CLIENT_OPTIONS)
    client.code = params[:code]
    response = client.fetch_access_token!
    google_api_token = GoogleApiSet.find_or_initialize_by(bot_id: bot.id)
    google_api_token.access_token = response['access_token']
    google_api_token.scope = response['scope']
    google_api_token.expires_in = response['expires_in']
    google_api_token.refresh_token = response['refresh_token']
    google_api_token.token_type = response['token_type']
    google_api_token.save!
    redirect_to bot_url(id: 1)
  end

  def create_event
    client = Signet::OAuth2::Client.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      access_token: Bot.find(1).google_api_set.access_token,
      refresh_token: Bot.find(1).google_api_set.refresh_token,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    )
    client.refresh!
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    calendar_id = "tktcorporation.go@gmail.com"
    unique_id = "tkt1212"
    event_id = Modules::Base32.encode32hex(unique_id).gsub("=","")
    event = Google::Apis::CalendarV3::Event.new({
          start: Google::Apis::CalendarV3::EventDateTime.new(date_time: DateTime.parse("2018-12-03T10:00").rfc3339),
          end: Google::Apis::CalendarV3::EventDateTime.new(date_time:DateTime.parse("2018-12-04T10:00").rfc3339),
          summary: 'aさん面談' ,
          description: '説明文',
          id: event_id,
        })
    service.insert_event(calendar_id, event)

  rescue Google::Apis::AuthorizationError
    response = client.refresh!
    google_api_token = GoogleApiSet.find_or_initialize_by(bot_id: 1)
    google_api_token.access_token = response['access_token']
    google_api_token.scope = response['scope']
    google_api_token.expires_in = response['expires_in']
    google_api_token.refresh_token = response['refresh_token']
    google_api_token.token_type = response['token_type']
    retry
  end

  def get_events
    client = Signet::OAuth2::Client.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      access_token: Bot.find(1).google_api_set.access_token,
      refresh_token: Bot.find(1).google_api_set.refresh_token,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    )
    client.refresh!

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    response = service.list_events("tktcorporation.go@gmail.com",
                                    max_results: 10,single_events: true,
                                    order_by: 'startTime',
                                    time_min: Time.now.iso8601)
    p "=============================="
    response.items.each do |event|
      p event.start.date_time.strftime("%Y-%m-%d %H:%M:%S")
      p event.end.date_time, event.summary
      p event.description
      p event.id
      p "=============================="
    end
    redirect_to "/"
  end






end