class  Manager
  require "digest/sha2"
  require 'securerandom'
  require 'json'
  require 'line/bot'  # gem 'line-bot-api'

  def self.client(bot)
    Line::Bot::Client.new { |config|
        config.channel_secret = bot.channel_secret
        config.channel_token = bot.channel_token
    }
  end

  def self.push(lineuser, text)
    saved_message = Message.new(content: text, lineuser_id: lineuser.id, to_bot: false)
    bot = lineuser.bot
    if saved_message.save
      puts("save success")
    end

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
    data = event['postback']['data'].match(/\[(?<id>.+)\](?<text>.+)/)
    quick_reply_item = QuickReplyItem.get(data[:id])
    response_data = lineuser.response_data.find_or_initialize_by(quick_reply_id: quick_reply_item.quick_reply_id)
    response_data.update_attributes!(response_text: data[:text])
    quick_reply = quick_reply_item.quick_reply
    if quick_reply_item.next_reply_id.present?
      switch_quick_reply_id = quick_reply_item.next_reply_id
      lineuser.update_attributes!(quick_reply_id: switch_quick_reply_id)
    else
      if quick_reply.next_reply_id.present?
        switch_quick_reply_id = quick_reply.next_reply_id
        lineuser.update_attributes!(quick_reply_id: switch_quick_reply_id)
      else
        lineuser.update_attributes!(quick_reply_id: quick_reply.next_reply_id)
      end
    end
    self.advance_lineuser_phase(lineuser, quick_reply.form)
  end

  def self.push_quick_reply(lineuser, quick_reply)
    bot = lineuser.bot
    message = {
      type: 'text',
      text: quick_reply.text,
      quickReply: QuickReply.quick_reply_items_param(quick_reply)
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

  def self.update_lineuser_profile(bot, uid)
    json_profile = self.client(bot).get_profile(uid).body
    profile = JSON.parse(json_profile)
    lineuser = Lineuser.get_with_uid(uid)
    lineuser.update(
      pictureUrl: profile['pictureUrl'],
      name: profile['displayName']
      )
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
    return message
  end

  def self.save_message(event, text)
    uid = event['source']['userId']
    lineuser = Lineuser.get_with_uid(uid)
    message = Message.new(content: text, lineuser_id: lineuser.id, to_bot: true)
    message.save
    log_text = "メッセージを受信：" + "from：[" + lineuser.name + "]  内容：" + text
    self.push_log(lineuser.bot.id, log_text)
    puts("seve succes")
    return message
  end

  def self.advance_lineuser_phase(lineuser, form)
    if quick_reply = QuickReply.extract_by_phase_of_lineuser(lineuser, form)
      if !quick_reply.is_normal_message
        self.push_quick_reply(lineuser, quick_reply)
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
        self.follow_event(lineuser)
      when Line::Bot::Event::Unfollow
        lineuser.quick_reply_id = nil
        lineuser.is_unfollowed = true
        lineuser.save
      when Line::Bot::Event::Postback
        self.postback_event(event, lineuser)
      when Line::Bot::Event::Message
        message = self.message_event(event, lineuser)
        lineuser.update_lastmessage(message)
      end
    end
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
    case event.type
    when Line::Bot::Event::MessageType::Text
      message = self.save_message_from_event(event)
    when Line::Bot::Event::MessageType::Image
      text = "[画像]"
    when Line::Bot::Event::MessageType::Video
      text = "[動画]"
    when Line::Bot::Event::MessageType::Audio
      text = "[音声]"
    when Line::Bot::Event::MessageType::File
      text = "[file]"
    when Line::Bot::Event::MessageType::Location
      text = "[位置情報]"
    when Line::Bot::Event::MessageType::Sticker
      #スタンプが送信されるとadvance_lineuser_phase
      if !ConvertedLineuser.get_with_lineuser(lineuser)
        if response_data = lineuser.response_data[0]
          form = response_data.quick_reply.form
        else
          form = Form.get_active_with_lineuser(lineuser)
        end
        if form
          self.advance_lineuser_phase(lineuser, form)
        end
      end
      text = "[スタンプ]"
    end
    if text
      message = self.save_message(event, text)
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
      puts "log crested"
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

end