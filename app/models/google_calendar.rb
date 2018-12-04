class GoogleCalendar
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'

  def self.callback_process(bot, code)
    client = Signet::OAuth2::Client.new(self.client_options(bot))
    client.code = code
    response = client.fetch_access_token!
    google_api_token = GoogleApiSet.find_or_initialize_by(bot_id: bot.id)
    google_api_token.access_token = response['access_token']
    google_api_token.scope = response['scope']
    google_api_token.expires_in = response['expires_in']
    google_api_token.refresh_token = response['refresh_token']
    google_api_token.token_type = response['token_type']
    google_api_token.save!
  end

  def self.create_event
    client = Signet::OAuth2::Client.new(
      client_id: Bot.find(1).google_api_set.client_id,
      client_secret: Bot.find(1).google_api_set.client_secret,
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
    #retry
  end

  def self.get_events
    client = Signet::OAuth2::Client.new(
      client_id: Bot.find(1).google_api_set.client_id,
      client_secret: Bot.find(1).google_api_set.client_secret,
      access_token: Bot.find(1).google_api_set.access_token,
      refresh_token: Bot.find(1).google_api_set.refresh_token,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    )
    client.refresh!

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    response = service.list_events("tktcorporation.go@gmail.com",
                                    max_results: 256,
                                    single_events: true,
                                    order_by: 'startTime',
                                    time_min: Time.now.iso8601,
                                    time_max: (Time.now + 24*60*60*7*0).iso8601)
    p "=============================="
    response.items.each do |event|
      p event.start.date_time.strftime("%Y-%m-%d %H:%M:%S")
      p event.end.date_time, event.summary
      p event.description
      p event.id
      p "=============================="
    end
    response.items
  end

  private
  def self.client_options(bot)
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