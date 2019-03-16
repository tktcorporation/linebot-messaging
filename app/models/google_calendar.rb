class GoogleCalendar
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'
  require 'time'
  require 'securerandom'
  require 'base64'

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

  def self.create_event(quick_reply, start_time, lineuser)
    retry_counter = 0
    bot = quick_reply.form.bot
    quick_reply_schedule = quick_reply.quick_reply_schedule
    if !bot.google_api_set.present?
      Manager.push_log(bot.id, "「GoogleApi」の設定がされていないため、カレンダーイベントの作成が行われませんでした。")
      return nil
    end
    client = Signet::OAuth2::Client.new(
      client_id: bot.google_api_set.client_id,
      client_secret: bot.google_api_set.client_secret,
      access_token: bot.google_api_set.access_token,
      refresh_token: bot.google_api_set.refresh_token,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    )
    client.refresh!
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    calendar_id = "primary"
    #unique_id = "catalist#{SecureRandom.hex(8)}"
    #event_id = "CDGN8OBCD5PN8"
    #Base64.strict_encode64(unique_id).gsub("=","")
    event = Google::Apis::CalendarV3::Event.new({
          start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time.rfc3339, time_zone: "Asia/Tokyo"),
          end: Google::Apis::CalendarV3::EventDateTime.new(date_time: (start_time + 60*30*(quick_reply_schedule.duration_num)).rfc3339, time_zone: "Asia/Tokyo"),
          summary: quick_reply_schedule.summary.to_s,
          description: "「#{quick_reply_schedule.summary}」, ユーザー：「#{lineuser.name}」"
          #id: event_id
        })
    service.insert_event(calendar_id, event)
    return true

  rescue Google::Apis::AuthorizationError
    response = client.refresh!
    google_api_token = GoogleApiSet.find_or_initialize_by(bot_id: bot.id)
    google_api_token.access_token = response['access_token']
    google_api_token.scope = response['scope']
    google_api_token.expires_in = response['expires_in']
    google_api_token.refresh_token = response['refresh_token']
    google_api_token.token_type = response['token_type']
    retry_counter += 1
    if retry_counter < 5
      retry
    else
      Manager.push_log(bot.id, "カレンダーイベントの作成に失敗しました。「GoogleApi」の設定を確認してください。")
    end
  end

  def self.get_events(bot)
    retry_counter = 0
    client = Signet::OAuth2::Client.new(
      client_id: bot.google_api_set.client_id,
      client_secret: bot.google_api_set.client_secret,
      access_token: bot.google_api_set.access_token,
      refresh_token: bot.google_api_set.refresh_token,
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
  rescue Google::Apis::AuthorizationError
    response = client.refresh!
    google_api_token = GoogleApiSet.find_or_initialize_by(bot_id: bot.id)
    google_api_token.access_token = response['access_token']
    google_api_token.scope = response['scope']
    google_api_token.expires_in = response['expires_in']
    google_api_token.refresh_token = response['refresh_token']
    google_api_token.token_type = response['token_type']
    retry_counter += 1
    if retry_counter < 5
      retry
    else
      Manager.push_log(bot.id, "カレンダーイベントの作成に失敗しました。「GoogleApi」の設定を確認してください。")
    end
  end

  def self.test_create_event(bot, start_time, duration)
    if !bot.google_api_set.present?
      Manager.push_log(bot.id, "「GoogleApi」の設定がされていないため、カレンダーイベントの作成が行われませんでした。")
      return nil
    end
    client = Signet::OAuth2::Client.new(
      client_id: bot.google_api_set.client_id,
      client_secret: bot.google_api_set.client_secret,
      access_token: bot.google_api_set.access_token,
      refresh_token: bot.google_api_set.refresh_token,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    )
    client.refresh!
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    calendar_id = "primary"
    event = Google::Apis::CalendarV3::Event.new({
          start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time.rfc3339),
          end: Google::Apis::CalendarV3::EventDateTime.new(date_time: (start_time + 60*30*duration).rfc3339),
          summary: "テストイベント",
          description: "テストイベント"
        })
    service.insert_event(calendar_id, event)
    return true
  rescue Google::Apis::AuthorizationError
    Manager.push_log(bot.id, "カレンダーイベントの作成に失敗しました。「GoogleApi」の設定を確認してください。")
  end

  private
  def self.client_options(bot)
    return client_option = {
      client_id: bot.google_api_set.client_id,
      client_secret: bot.google_api_set.client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://www.googleapis.com/oauth2/v4/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri:"https://#{ENV.fetch('DOMAIN_NAME')}/google_auth/callback/#{bot.callback_hash}",
      additional_parameters: {prompt:'consent'},
    }
  end

  def self.ids
    service.list_calendar_lists.items.map(&id)
  end

  def self.client

  end

end