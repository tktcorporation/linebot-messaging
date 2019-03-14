class Lineuser < ApplicationRecord
  include SearchCop

  search_scope :search do
    attributes :name
    attributes session_time: "session_lineuser.created_at"
    attributes convert_time: "converted_lineuser.created_at"
    #attributes message: "messages.content"
    attributes lastmessage_created_at: "lastmessage.created_at"
  end

  has_many :messages, ->{ where(deleted: false).order(created_at: :asc) }
  has_many :response_data, dependent: :destroy
  has_one :converted_lineuser, dependent: :destroy
  has_one :session_lineuser, dependent: :destroy
  has_one :quick_reply, class_name: 'QuickReply', primary_key: :quick_reply_id, foreign_key: :id
  has_one :lastmessage, class_name: 'Message', primary_key: :lastmessage_id, foreign_key: :id, dependent: :destroy
  has_one :lineuser_status, class_name: "Bot::LineuserStatus", dependent: :destroy
  has_many :quick_reply_text_flags, dependent: :destroy
  belongs_to :bot

  validates :uid, presence: true, lt4bytes: true
  validates :bot_id, numericality: true
  validates :pictureUrl, lt4bytes: true


  scope :unfollowed, ->{ where(is_unfollwed: false) }

  def self.custom_search(lineusers, search_params)
    if !search_params[:name].blank?
      lineusers = lineusers.search("name: #{search_params[:name]}")
    end
    if !search_params[:convert_time_from].blank?
      lineusers = lineusers.search("convert_time > #{search_params[:convert_time_from]}")
    end
    if !search_params[:convert_time_to].blank?
      lineusers = lineusers.search("convert_time < #{search_params[:convert_time_to]}")
    end
    if !search_params[:session_time_from].blank?
      lineusers = lineusers.search("session_time > #{search_params[:session_time_from]}")
    end
    if !search_params[:session_time_to].blank?
      lineusers = lineusers.search("session_time < #{search_params[:session_time_to]}")
    end
    if !search_params[:messages_created_at_from].blank?
      lineusers = lineusers.search("lastmessage_created_at > #{search_params[:messages_created_at_from]}")
    end
    if !search_params[:messages_created_at_to].blank?
      lineusers = lineusers.search("lastmessage_created_at < #{search_params[:messages_created_at_to]}")
    end
    if !search_params[:limit].blank?
      lineusers = lineusers.limit(search_params[:limit].to_i)
    end
    lineusers
  end
  def add_phase_count
    self.phase += 1
    save
  end

  def convert(form)
    converted_lineuser = ConvertedLineuser.find_or_initialize_by(lineuser_id: self.id)
    converted_lineuser.form_id = form.id
    converted_lineuser.save
    Manager.push_slack_lineuser_data(self)
  end

  def create_session(form)
    session_lineuser = SessionLineuser.find_or_initialize_by(lineuser_id: self.id)
    session_lineuser.form_id = form.id
    session_lineuser.save
  end

  def is_converted
    self.converted_lineuser.present? ? true : false
  end

  def set_next_reply_id(next_reply_id)
    self.update_attributes!(quick_reply_id: next_reply_id)
  end

  def get_response_data_message
    result_text = "プロフィール"
    result_text += "\nname: #{self.name}"
    result_text += "\nuser_id: #{self.uid}"
    result_text += "\nフォーム名：#{self.session_lineuser.form.name}"
    result_text += "\n回答データ"
    self.response_data.includes(:quick_reply).each do |data|
      if data.quick_reply.present?
        text = "\n#{data.quick_reply.name}: #{data.response_text}"
        result_text += text
      end
    end
    result_text
  end

  def self.get_plural_with_bot_id(bot_id)
    bot = Bot.get(bot_id)
    self.where(bot_id: bot.id)
  end

  def self.get_plural_with_remind_id(remind_id)
    remind = Remind.get(remind_id)
    self.where(bot_id: remind.bot_id)
  end

  def self.get_with_uid(uid)
    self.find_by(uid: uid)
  end

  def self.get(lineuser_id)
    self.find(lineuser_id)
  end

  def self.find_or_create(uid, bot_id)
    if lineuser = self.get_with_uid(uid)
      lineuser
    else
      if lineuser = self.create!(uid: uid, bot_id: bot_id)
        p "created new lineuser"
        lineuser
      end
    end
  end

  def update_lastmessage(message)
    self.update_attributes!(lastmessage_id: message.id)
  end

  def get_invitation_code
    #Manager.encrypt(self.uid + "invitexxx").slice(0, 8)
    code = ""
    5.times{ a += ("A".."Z").to_a.sample}
    code
  end

end