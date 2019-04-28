class Message < ApplicationRecord
  belongs_to :lineuser

  validates :content, presence: true
  validates :lineuser_id, numericality: true
  validates :to_bot, inclusion: { in: [true, false] }
  validates :msg_type, numericality: true

  scope :undeleted, ->{ where(deleted: false) }
  scope :order_asc, ->{ order(created_at: :asc) }

  def self.get_plural_with_lineuser_id(lineuser_id)
    Message.where(lineuser_id: lineuser_id).order_asc
  end

  def self.get(id)
    self.find(id)
  end

  def self.create_quick_reply_message(lineuser, quick_reply)
    message = self.new(content: "クイックリプライ：" + quick_reply.name, lineuser_id: lineuser.id, to_bot: false, msg_type: 0)
    message.save!
    message
  end

  def self.create_normal(lineuser, to_bot, content)
    message = self.new(lineuser_id: lineuser.id, to_bot: false, content: content, msg_type: 0)
    message.save!
    message
  end

  def self.create_image(lineuser, to_bot, stock_image)
    message = self.new(lineuser_id: lineuser.id, to_bot: false, content: "[画像: #{stock_image.id}::#{stock_image.image.url}]", msg_type: 1)
    message.save!
    message
  end

  def self.create_with_type(lineuser, to_bot, type, content)
    Rails.logger.debug "type"
    Rails.logger.debug type
    Rails.logger.debug type.class
    if !(type.class == Integer)
      type = 0
      Rails.logger.fatal "msg_type is not Integer. [Message.create_with_type]"
    end
    message = self.new(lineuser_id: lineuser.id, to_bot: true, msg_type: type, content: content)
    message.save!
    message
  end

  # def self.bulk_insert(lineusers, text, to_bot)
  #   # new_models は配列となります
  #   message_models = []
  #   lineusers.each {|lineuser|
  #       message_models << self.new(
  #           content: text,
  #           lineuser_id: lineuser.id,
  #           to_bot: false
  #       )
  #   }
  #   self.import message_models
  # end
end