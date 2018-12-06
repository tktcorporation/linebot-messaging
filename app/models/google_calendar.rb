class GoogleCalendar
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'
  require 'time'

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
    calendar_id = "primary"
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
    ids = service.list_calendar_lists.items.map(&:id)

    calendar_items = []
    ids.each do |calendar_id|
      response = service.list_events(calendar_id,
        time_min: Time.now.iso8601,
        time_max: (Time.now + 7.days).iso8601
        )
      response.items.each do |calendar_item|
        calendar_items.push(calendar_item)
      end
    end

    p "===========イベント一覧==========="
    calendar_items.each do |event|
      if event.start.date.present?
        p "start_date:" + event.start.date
        p "end_date:" + event.end.date
      else
        p "start_date-time:" + event.start.date_time.strftime("%Y-%m-%d %H:%M:%S")
        p "end_date-time:" + event.end.date_time.strftime("%Y-%m-%d %H:%M:%S")
      end
      p "summary:" + event.summary
      p "description:" + event.description if event.description.present?
      p "id:" + event.id
      p "=============================="
    end
    return calendar_items
  end

  def self.quick_reply_days(quick_reply)
    return nil if quick_reply.reply_type != 3
    day = Time.now
    duration_days = quick_reply.quick_reply_schedule.duration_days
    items_array = []
    duration_days.times do |i|
      day += 60*60*24 if i != 0
      data = "[#{quick_reply.reply_type}][#{quick_reply.id}]" + day.strftime("%Y-%m-%d")
      pushed_item = {:type=>"action",
                :action=>{
                          :type => "postback",
                          :label => day.strftime("%m月%d日"),
                          :data => data,
                          :text => day.strftime("%m月%d日")
                          }
              }
      items_array.push(pushed_item)
    end
    quick_reply = {:items => items_array}
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

  def self.ids
    service.list_calendar_lists.items.map(&id)
  end

  def self.client

  end

end