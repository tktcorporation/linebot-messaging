class  Manager
  require "digest/sha2"
  require 'securerandom'
  require 'json'
  require 'line/bot'  # gem 'line-bot-api'
  require "time"

  def self.client(bot)
    Line::Bot::Client.new { |config|
        config.channel_secret = bot.channel_secret
        config.channel_token = bot.channel_token
    }
  end

  def self.push(lineuser, text)
    saved_message = Message.new(content: text, lineuser_id: lineuser.id, to_bot: false)
    bot = lineuser.bot
    saved_message.save!

    message = {
      type: 'text',
      text: text
    }

    if response = self.client(bot).push_message(lineuser.uid, message)
      p response
      lineuser.update_lastmessage(saved_message)
      log_text = "メッセージを送信：" + "to：[" + lineuser.name + "]  内容：" + text + ""
      self.push_log(bot.id, log_text)
    end
    #return UrlFetchApp.fetch(url, options);
  end

  def self.push_multicast(lineusers, text)
    message = {
      type: 'text',
      text: text
    }
    bot = lineusers[0].bot
    response = self.client(bot).multicast(lineusers.map{|user| user.uid}, message)
    if response.class == Net::HTTPOK
      lineusers.each do |lineuser|
        saved_message = Message.new(content: text, lineuser_id: lineuser.id, to_bot: false)
        saved_message.save!
        lineuser.update_lastmessage(saved_message)
        log_text = "メッセージを送信：" + "to：[" + lineuser.name + "]  内容：" + text + ""
        self.push_log(bot.id, log_text)
      end
    else
      p "response.class != Net::HTTPOK"
    end
    #return UrlFetchApp.fetch(url, options);
  end

  def self.postback_event(event, lineuser)
    data = event['postback']['data'].match(/\[(?<reply_type>.+)\]\[(?<id>.+)\](?<text>.+)/)
    message = Message.new(content: data[:text], lineuser_id: lineuser.id, to_bot: true)
    if message.save
      p "save success"
      lineuser.update_lastmessage(message)
    end
    case data[:reply_type].to_i
    when 1
      #data[:id]にはquick_reply_item_idが入っている
      quick_reply_item = QuickReplyItem.get(data[:id])
      quick_reply = quick_reply_item.quick_reply
      ResponseDatum.save_data(lineuser, quick_reply.id, data[:text])
      self.set_lineuser_to_next_reply_id(lineuser, quick_reply_item)
      self.advance_lineuser_phase(lineuser, quick_reply.form)
    when 3
      #data[:id]にはquick_reply_idが入っている
      quick_reply = QuickReply.get(data[:id])
      day = Time.parse(data[:text])
      message = {
        type: 'text',
        text: day.strftime("%m月%d日"),
        quickReply: quick_reply.times_param(day)
      }
      self.client(lineuser.bot).push_message(lineuser.uid, message)
    when 4
      #data[:id]にはquick_reply_idが入っている
      quick_reply = QuickReply.get(data[:id])
      ResponseDatum.save_data(lineuser, quick_reply.id, data[:text])
      #ここに確認処理をはさむ必要があるかもしれない
      message = {
        type: 'text',
        text: "「#{data[:text]}」で決定しますか",
        quickReply: quick_reply.check_param
      }
      self.client(lineuser.bot).push_message(lineuser.uid, message)
    when 99
      quick_reply = QuickReply.get(data[:id])
      case data[:text]
      when "決定"
        case quick_reply.reply_type.to_i
        when 3
          response_text = quick_reply.response_datum.response_text
          day = Time.parse(response_text)
          GoogleCalendar.create_event(quick_reply, day, lineuser)
          self.set_lineuser_to_next_reply_id(lineuser, quick_reply)
          self.advance_lineuser_phase(lineuser, quick_reply.form)
         when 2
          QuickReplyTextFlag.accepted(lineuser)
          self.set_lineuser_to_next_reply_id(lineuser, quick_reply)
          self.advance_lineuser_phase(lineuser, quick_reply.form)
        end
      when "戻る"
        self.advance_lineuser_phase(lineuser, quick_reply.form)
      end
    end

  end

  def self.set_lineuser_to_next_reply_id(lineuser, quick_reply_or_item)
    case quick_reply_or_item
    when QuickReplyItem
      quick_reply_item = quick_reply_or_item
      if quick_reply_item.next_reply_id.present?
        switch_quick_reply_id = quick_reply_item.next_reply_id
        lineuser.set_next_reply_id(switch_quick_reply_id)
      else
        self.set_next_reply_id_from_quick_reply(quick_reply_item.quick_reply, lineuser)
      end
    when QuickReply
      quick_reply = quick_reply_or_item
      self.set_next_reply_id_from_quick_reply(quick_reply, lineuser)
    end
  end

  def self.set_next_reply_id_from_quick_reply(quick_reply, lineuser)
    #quick_reply_itemを無視、quick_replyのnext_reply_idのみを参照してlineuserにnext_reply_idをセットする
    if quick_reply.next_reply_id.present?
      switch_quick_reply_id = quick_reply.next_reply_id
      lineuser.set_next_reply_id(switch_quick_reply_id)
    else
      lineuser.set_next_reply_id(nil)
    end
  end

  def self.push_quick_reply(lineuser, quick_reply)
    bot = lineuser.bot
    case quick_reply.reply_type
    when 1
      message = {
        type: 'text',
        text: quick_reply.text,
        quickReply: quick_reply.items_param
      }
    when 2
      message = {
        type: 'text',
        text: quick_reply.text
      }
      QuickReplyTextFlag.initialize_accepting(quick_reply, lineuser)
    when 3
      message = {
        type: 'text',
        text: quick_reply.text,
        quickReply: quick_reply.days_param
      }
    end
    response = self.client(bot).push_message(lineuser.uid, message)
    if response.class == Net::HTTPOK
      message = Message.new(content: "クイックリプライ：" + quick_reply.name, lineuser_id: lineuser.id, to_bot: false)
      if message.save
        puts("save success")
        lineuser.update_lastmessage(message)
      end
    end
  end

  def self.push_flex(lineuser, quick_reply)
    bot = lineuser.bot
    case quick_reply.reply_type
    when 1
      message = Manager::Flex.set_flex(quick_reply.text, quick_reply.items_param)
    when 2
      message = {
        type: 'text',
        text: quick_reply.text
      }
      QuickReplyTextFlag.initialize_accepting(quick_reply, lineuser)
    when 3
      message = {
        type: 'text',
        text: quick_reply.text,
        quickReply: quick_reply.days_param
      }
    end
    response = self.client(bot).push_message(lineuser.uid, message)
    if response.class == Net::HTTPOK
      message = Message.new(content: "flexメッセージ：" + quick_reply.name, lineuser_id: lineuser.id, to_bot: false)
      message.save!
      puts("save success")
      lineuser.update_lastmessage(message)
    else
      p response
    end
  end

  def self.update_lineuser_profile(bot, uid)
    response = self.client(bot).get_profile(uid).body
    p response
    profile = JSON.parse(response)
    lineuser = Lineuser.get_with_uid(uid)
    lineuser.update(pictureUrl: profile['pictureUrl'])#,name: profile['displayName']
  end

  def self.get_last_message(lineuser_id)
    Message.get_plural_with_lineuser_id(lineuser_id).last
  end

  def self.get_last_messages(lineusers_list)
    lineusers_list.map{|lineuser|self.get_last_message(lineuser.id)}
  end

  def self.push_name(lineuser_id, username)
    lineuser = Lineuser.get(lineuser_id)
    if lineuser.update(name: username)
      puts("update success")
    end
  end

  def self.save_message_from_event(event)
    uid = event['source']['userId']
    text = event.message['text']
    lineuser = Lineuser.get_with_uid(uid)
    message = Message.create!(content: text, lineuser_id: lineuser.id, to_bot: true)
    log_text = "メッセージを受信：" + "from：[" + lineuser.name + "]  内容：" + text
    self.push_log(lineuser.bot_id, log_text)
    puts("seve message succes")
    self.check_quick_reply_text(lineuser, text)
    return message
  end

  def self.check_quick_reply_text(lineuser, text)
    return nil if /回答：.+/ === text
    if lineuser.quick_reply_text_flags.present?
      if lineuser.quick_reply_text_flags.find_by(is_accepting: true).present?
        quick_reply = lineuser.quick_reply_text_flags.find_by(is_accepting: true).quick_reply_text.quick_reply
        #確認処理
        if text.length < 255
          ResponseDatum.save_data(lineuser, quick_reply.id, text)
          message = {
            type: 'text',
            text: "「#{text}」で決定しますか",
            quickReply: quick_reply.check_param
          }
          self.client(lineuser.bot).push_message(lineuser.uid, message)
        else
          self.push(lineuser, "255字以内で入力してください。")
        end
      end
    end
  end

  def self.save_message(event, type, text)
    uid = event['source']['userId']
    lineuser = Lineuser.get_with_uid(uid)
    message = Message.new(content: text, lineuser_id: lineuser.id, to_bot: true, msg_type: type)
    message.save
    log_text = "メッセージを受信：" + "from：[" + lineuser.name + "]  内容：" + text
    self.push_log(lineuser.bot.id, log_text)
    puts("seve succes")
    return message
  end

  def self.advance_lineuser_phase(lineuser, form)
    if quick_reply = QuickReply.extract_by_phase_of_lineuser(lineuser, form)
      if !quick_reply.is_normal_message || quick_reply.reply_type != 0
        self.push_flex(lineuser, quick_reply)
      else
        self.push(lineuser, quick_reply.text)
        next_reply_id = QuickReply.find(lineuser.quick_reply_id).next_reply_id
        lineuser.quick_reply_id = next_reply_id
        self.advance_lineuser_phase(lineuser, form)
      end
    else
      lineuser.convert(form)
    end
    lineuser.save!
  end

  def self.start_event(event, bot_id)
    uid = event['source']['userId']
    if uid != "Udeadbeefdeadbeefdeadbeefdeadbeef"
      lineuser = Lineuser.find_or_create(uid, bot_id)
      case event
      when Line::Bot::Event::Follow
        ActiveRecord::Base.transaction do
          self.follow_event(lineuser)
        end
      when Line::Bot::Event::Unfollow
        lineuser.quick_reply_id = nil
        lineuser.is_unfollowed = true
        lineuser.save
      when Line::Bot::Event::Postback
        ActiveRecord::Base.transaction do
          self.postback_event(event, lineuser)
        end
      when Line::Bot::Event::Message
        message = self.message_event(event, lineuser)
        lineuser.update_lastmessage(message)
      end
    end
  rescue => e
    Rails.logger.fatal e.message
  end

  def self.follow_event(lineuser)
    lineuser.is_unfollowed = false
    lineuser.save
    self.update_lineuser_profile(lineuser.bot, lineuser.uid)
    if form = Form.get_active_with_lineuser(lineuser)
      lineuser.create_session(form)
      lineuser.update_attributes(quick_reply_id: form.first_reply_id)
      self.advance_lineuser_phase(lineuser, form)
    end
  end

  def self.message_event(event, lineuser)
    id = "id=" + event.message['id']
    case event.type
    when Line::Bot::Event::MessageType::Text
      message = self.save_message_from_event(event)
    when Line::Bot::Event::MessageType::Image
      text = "[画像][{id}]"
      type = 1
    when Line::Bot::Event::MessageType::Video
      text = "[動画][#{id}]"
      type = 2
    when Line::Bot::Event::MessageType::Audio
      text = "[音声][#{id}]"
      type = 3
    when Line::Bot::Event::MessageType::File
      text = "[file][#{id}]"
      type = 4
    when Line::Bot::Event::MessageType::Location
      text = "[位置情報]"
      type = 5
    when Line::Bot::Event::MessageType::Sticker
      #スタンプが送信されるとadvance_lineuser_phase
      if !lineuser.is_converted
        form = Form.get_active_with_lineuser(lineuser)
        if form
          self.advance_lineuser_phase(lineuser, form)
        end
      end
      text = "[スタンプ]"
    end
    if text
      message = self.save_message(event, type, text)
    end
    if message
      return message
    end
  end

  def self.new_callback_hash
    SecureRandom.urlsafe_base64
  end

  def self.remindcheck_and_push
    reminds = Remind.all_of_enable
    reminds.each do |remind|
      if remind.ignition_time < Time.now
        log_text = "リマインド：" + remind.name + "を実行しました。"
        self.push_log(remind.bot_id, log_text)
        remind_users = RemindUser.get_plural_with_remind_id(remind.id)
        self.push_multicast(remind_users.map{|user| user.lineuser}, remind.text)
        remind.update(completed: true)
      end
    end
  end

  def self.push_log(bot_id, text)
    if Log.create(bot_id: bot_id, text: text)
      if Bot.get(bot_id).notify
        notify_token = NotifyToken.get_with_bot_id(bot_id).access_token
        LineNotify.send(text, notify_token)
      end
      puts "log created"
    end
  end

  def self.create_new_bot(bot_params, current_user_id)
    if !Bot.get_with_channel_secret(bot_params[:channel_secret])
      bot = Bot.new(bot_params)
      bot.callback_hash = self.new_callback_hash
      bot.user_id = current_user_id
      if bot.save
        puts "new bot created"
        return true
      end
    end
    false
  end

  def self.create_remind(remind_params, bot_id, lineuser_id_array)
    Remind.transaction do
      bot = Bot.get(bot_id)
      remind = bot.reminds.create(remind_params)
      lineuser_id_array.each do |lineuser_id|
        remind.remind_users.create(lineuser_id: lineuser_id)
      end
    end
  rescue => e
    raise e.message
  end

  def self.update_remind(remind_id, remind_params, lineuser_id_array)
    Remind.transaction do
      remind = Remind.get(remind_id)
      remind.update(remind_params)
      remind.remind_users.destroy_all
      lineuser_id_array.each do |lineuser_id|
        remind.remind_users.create(lineuser_id: lineuser_id)
      end
    end
  rescue => e
    render plain: e.message
  end

  def self.encrypt(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  def self.sort_by_is_replied(lineusers)
    lineusers = lineusers.includes(:lastmessage).order("messages.created_at desc")
    sorted_lineusers = { :replied => [], :not_replied => [] }
    lineusers.each do |lineuser|
      if lastmessage = lineuser.lastmessage
        case lastmessage.to_bot
        # 最後のメッセージがボットへのもの∴未返信メッセージ
        when true
          sorted_lineusers[:not_replied].push(lineuser)
        # 最後のメッセージがユーザーへのもの∴返信済メッセージ
        when false
          sorted_lineusers[:replied].push(lineuser)
        end
      else
        sorted_lineusers[:replied].push(lineuser)
      end
    end
    sorted_lineusers
  end

  def self.available_time(calendar_event, day, available_array)
    time = Time.local(day.year, day.month, day.day, 0, 0, 0, 0)
    if calendar_event.start.date.present?
      if Time.parse(calendar_event.start.date) <= time && time < Time.parse(calendar_event.end.date)
        filled_array = []
        48.times do |i|
          filled_array.push(1)
        end
        available_array = filled_array
      end
    else
      48.times do |i|
        start_period = time + (60*30*i)
        end_period = time + (60*30*(i+1))
        if calendar_event.start.date_time.to_time <= end_period && start_period <= calendar_event.end.date_time.to_time
          p start_period
          available_array[i] = 1
        end
      end
    end
    available_array
  end

  def self.extract_free_time(available_array_week, day)
    #lineuser = Lineuser.get(13)
    p "直近1週間で空いている日は"
    #self.push(lineuser, "直近1週間で空いている日は")
    7.times do |i|
      p (day + (60*60*24*(i))).strftime("%Y年 %m月%d日")
      #self.push(lineuser, (day + (60*60*24*(i))).strftime("%Y年 %m月%d日"))
      48.times do |j|
        time = Time.local(day.year, day.month, day.day, 0, 0, 0, 0)
        if available_array_week[i][j] == 0
          start_time = time + (60*30*(j))
          end_time = time + (60*30*(j+1))
          p "#{start_time.strftime("%H:%M")} ~ #{end_time.strftime("%H:%M")}"
          #self.push(lineuser, "#{start_time.strftime("%H:%M")} ~ #{end_time.strftime("%H:%M")}")
        end
      end
    end
  end

  def self.available_array_week(day)
    calendar_events = GoogleCalendar.get_events
    available_array_week = []
    7.times do |i|
      available_array = []
      48.times do |j|
        available_array.push(0)
      end
      available_array = self.available_array_day(calendar_events, day + (60*60*24*(i)), available_array)
      available_array_week.push(available_array)
    end
    p available_array_week
    available_array_week
  end

  def self.available_array_day(calendar_events, day, available_array)
    calendar_events.each do |event|
      available_array = Manager.available_time(event, day, available_array)
    end
    return available_array
  end

  def self.push_quick_reply_calendar(lineuser, quick_reply)
    bot = lineuser.bot
    message = {
        type: 'text',
        text: quick_reply.text,
        quickReply: QuickReply.quick_reply_items(quick_reply)
      }
    response = self.client(bot).push_message(lineuser.uid, message)
    if response.class == Net::HTTPOK
      message = Message.new(content: "クイックリプライ：" + quick_reply.name, lineuser_id: lineuser.id, to_bot: false)
      if message.save
        puts("save success")
        lineuser.update_lastmessage(message)
      end
    end
  end

  def self.get_img_binary(message)
    bot = message.lineuser.bot
    msg = message.content.match(/.+\[id=(?<id>.+)\]/)
    return false if msg.blank?
    self.client(bot).get_message_content(msg[:id])
  end
end