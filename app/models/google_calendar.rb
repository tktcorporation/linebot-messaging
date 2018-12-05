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

    p calendar_items.inspect

    p "===========イベント一覧==========="
    calendar_items.each do |event|
      p "start:" + event.start.date_time#.strftime("%Y-%m-%d %H:%M:%S") if event.start
      p "end:" + event.end.date_time#.strftime("%Y-%m-%d %H:%M:%S") if event.end
      p "summary:" + event.summary
      p "description:" + event.description
      p "id:" + event.id
      p "=============================="
    end
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





[#<Google::Apis::CalendarV3::Event:0x000055cd8c37dd68 @created=Wed, 21 Nov 2018 06:50:18 +0000, @creator=#<Google::Apis::CalendarV3::Event::Creator:0x000055cd8ca4c450 @email=\"tktcorporation.go@gmail.com\", @self=true>, @description=\"https://supporterzcolab.com/event/629/\", @end=#<Google::Apis::CalendarV3::EventDateTime:0x000055cd8ca35570 @date_time=Fri, 07 Dec 2018 21:30:00 +0900>, @etag=\"\\\"3085566037420000\\\"\", @extended_properties=#<Google::Apis::CalendarV3::Event::ExtendedProperties:0x000055cd8ca128e0 @private={\"everyoneDeclinedDismissed\"=>\"-1\"}>, @html_link=\"https://www.google.com/calendar/event?eid=MGNzODZwc2lvc25la2I4cGxpOWZhazh1b3MgdGt0Y29ycG9yYXRpb24uZ29AbQ\", @i_cal_uid=\"0cs86psiosnekb8pli9fak8uos@google.com\", @id=\"0cs86psiosnekb8pli9fak8uos\", @kind=\"calendar#event\", @location=\"東京都渋谷区道玄坂1-9-5\", @organizer=#<Google::Apis::CalendarV3::Event::Organizer:0x000055cd8c9fc8d8 @email=\"tktcorporation.go@gmail.com\", @self=true>, @reminders=#<Google::Apis::CalendarV3::Event::Reminders:0x000055cd8c9e8b80 @use_default=true>, @sequence=0, @start=#<Google::Apis::CalendarV3::EventDateTime:0x000055cd8c9d2790 @date_time=Fri, 07 Dec 2018 19:30:00 +0900>, @status=\"confirmed\", @summary=\"【初心者歓迎】サポーターズCoLabビギナーズLT会vol.3\", @updated=Wed, 21 Nov 2018 06:50:18 +0000>,

#<Google::Apis::CalendarV3::Event:0x000055cd8c9aed40 @created=Tue, 04 Dec 2018 08:45:16 +0000, @creator=#<Google::Apis::CalendarV3::Event::Creator:0x000055cd8c98f378 @email=\"tktcorporation.go@gmail.com\", @self=true>, @end=#<Google::Apis::CalendarV3::EventDateTime:0x000055cd8c98d848 @date=\"2018-12-06\">, @etag=\"\\\"3087826233926000\\\"\", @html_link=\"https://www.google.com/calendar/event?eid=XzYwc2syZTltODUya2FiYTM2Z3M0YWI5azZoMTQyYjlwNnNza2NiOWo4OHNqNGdwaDhnczNhZDFsNzQgdGt0Y29ycG9yYXRpb24uZ29AbQ\", @i_cal_uid=\"09A96AEE-C48E-44BA-979F-3B92C1D85459\", @id=\"_60sk2e9m852kaba36gs4ab9k6h142b9p6sskcb9j88sj4gph8gs3ad1l74\", @kind=\"calendar#event\", @organizer=#<Google::Apis::CalendarV3::Event::Organizer:0x000055cd8c978c40 @email=\"tktcorporation.go@gmail.com\", @self=true>, @reminders=#<Google::Apis::CalendarV3::Event::Reminders:0x000055cd8c943b58 @use_default=false>, @sequence=0, @start=#<Google::Apis::CalendarV3::EventDateTime:0x000055cd8c942780 @date=\"2018-12-05\">, @status=\"confirmed\", @summary=\"テスト1\", @updated=Tue, 04 Dec 2018 08:45:16 +0000>,

#<Google::Apis::CalendarV3::Event:0x000055cd8c79a3d8 @created=Mon, 01 Jan 1900 12:00:00 +0000, @creator=#<Google::Apis::CalendarV3::Event::Creator:0x000055cd8c786f40 @email=\"v7jdsf4l6v951qohtouunbvcrfvrq0e6@import.calendar.google.com\", @self=true, @display_name=\"https://trello.com/calendar/5ab1186147ea728e3af0a89d/5ba89683588ec77c914bde27/ddeafff0b4cbf4d83bf46c6add76fa68.ics\">, @description=\"社内運用用\\n複数サーバーでproduction運用開始\\n\\nCard URL: https://trello.com/c/Jw26RPz0\\nNo Assigned Members\", @end=#<Google::Apis::CalendarV3::EventDateTime:0x000055cd8c784ab0 @date_time=Mon, 10 Dec 2018 11:00:00 +0000>, @etag=\"\\\"3081980822192000\\\"\", @html_link=\"https://www.google.com/calendar/event?eid=XzZsaDY4ZWIxNjhvamljMzI2OHBqY2U5bWNvcTY4cGoyNjRvajZlMjBlaHA2YXIzY2RzbjY2cnJkIHY3amRzZjRsNnY5NTFxb2h0b3V1bmJ2Y3JmdnJxMGU2QGk\", @i_cal_uid=\"5bd9a2190b23696f4dfb1138@trello.com\", @id=\"_6lh68eb168ojic3268pjce9mcoq68pj264oj6e20ehp6ar3cdsn66rrd\", @kind=\"calendar#event\", @organizer=#<Google::Apis::CalendarV3::Event::Organizer:0x000055cd8c75faa8 @email=\"v7jdsf4l6v951qohtouunbvcrfvrq0e6@import.calendar.google.com\", @self=true, @display_name=\"https://trello.com/calendar/5ab1186147ea728e3af0a89d/5ba89683588ec77c914bde27/ddeafff0b4cbf4d83bf46c6add76fa68.ics\">, @reminders=#<Google::Apis::CalendarV3::Event::Reminders:0x000055cd8c75d550 @use_default=true>, @sequence=0, @start=#<Google::Apis::CalendarV3::EventDateTime:0x000055cd8c74fa40 @date_time=Mon, 10 Dec 2018 10:00:00 +0000>, @status=\"confirmed\", @summary=\"linebot-messaging[β版]リリース [期限設定済み]\", @updated=Wed, 31 Oct 2018 12:53:31 +0000>]