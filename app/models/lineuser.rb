class Lineuser < ApplicationRecord
  include SearchCop

  search_scope :search do
    attributes :name
    attributes status_id: "status.id"
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
  has_one :status, class_name: "Bot::Status", through: :lineuser_status
  has_one :invitation_code, dependent: :destroy
  has_many :quick_reply_text_flags, dependent: :destroy
  belongs_to :bot

  validates :uid, presence: true, lt4bytes: true
  validates :bot_id, numericality: true
  validates :pictureUrl, lt4bytes: true


  scope :followed, ->{ where(is_unfollowed: false) }

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
    if !search_params[:status_id].blank? && search_params[:status_id].to_i != 0
      lineusers = lineusers.search("status_id: #{search_params[:status_id]}")
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
    # 最後に投げられたformのidでコンバート
    # converted_lineuser.form_id = form.id
    # sessionとconvertを一致させる
    converted_lineuser.form_id = session_lineuser.form_id
    converted_lineuser.save!
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
    result_text += "\nフォーム名：#{self.session_lineuser&.form&.name}"
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

  def self.filter_status(status_id)
    self.joins(:lineuser_status).where("bot_lineuser_statuses.status_id = #{status_id}")
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

  def self.update_lastmessage_bulk(lineusers_messages)
      lineuser_models = []
      lineusers_messages.each {|lineuser_message|
        lineuser = lineuser_message[0]
        message = lineuser_message[1]
        lineuser.lastmessage_id = message.id
        lineuser_models << lineuser
      }
      self.import lineuser_models, on_duplicate_key_update: [:lastmessage_id]
  end

  def update_lastmessage(message)
    self.update_attributes!(lastmessage_id: message.id)
  end

  def get_invitation_code
    #Manager.encrypt(self.uid + "invitexxx").slice(0, 8)
    if code = self.invitation_code&.code
      return code
    else
      code = ""
      5.times{ code += ("A".."Z").to_a.sample}
      invitation_code = self.build_invitation_code(code: code)
      invitation_code.save!
      return code
    end
  end

  def follow_status_text
    "ユーザー名：#{self.name}\nユーザーID：#{self.uid}\nステータス：#{self.is_unfollowed ? "ブロック" : "フォロー"}"
  end

end